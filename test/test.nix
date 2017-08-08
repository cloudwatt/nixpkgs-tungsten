import <nixpkgs/nixos/tests/make-test.nix> {
  machine =
    { config, pkgs, ... }:
    let
      contrailPkgs = import ../controller.nix { inherit pkgs; };

      cassandraPkg = pkgs.cassandra_2_1.override {jre = pkgs.jre7;};
      cassandraConfigDir = pkgs.runCommand "cassandraConfDir" {} ''
        mkdir -p $out
        
        cat ${pkgs.cassandra_2_1}/conf/cassandra.yaml > $out/cassandra.yaml
        cat >> $out/cassandra.yaml << EOF
        data_file_directories:
            - /tmp/cassandra-data/data
        commitlog_directory:
            - /tmp/cassandra-data/commitlog
        saved_caches_directory:
            - /tmp/cassandra-data/saved_caches
        EOF

        cat >> $out/log4j-server.properties << EOF
        log4j.rootLogger=INFO,stdout
        log4j.appender.stdout=org.apache.log4j.ConsoleAppender
        log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
        log4j.appender.stdout.layout.ConversionPattern=%5p [%t] %d{HH:mm:ss,SSS} %m%n
        EOF
      '';
      api = pkgs.writeTextFile {
        name = "contrail-api.conf";
        text = ''
          [DEFAULTS]
          log_file = /var/log/contrail/api.log
          log_level = SYS_DEBUG
          log_local = 1
          cassandra_server_list = localhost:9160
          disc_server_ip = localhost
          disc_server_port = 5998

          rabbit_port = 5672
          rabbit_server = localhost
          listen_port = 8082
          listen_ip_addr = 0.0.0.0
          zk_server_port = 2181
          zk_server_ip = localhost


          [IFMAP_SERVER]
          ifmap_listen_ip = 0.0.0.0
          ifmap_listen_port = 8443
          ifmap_credentials = api-server:api-server
        '';
      };
      discovery = pkgs.writeTextFile {
        name = "contrail-discovery.conf";
        text =
          ''
          [DEFAULTS]
          zk_server_ip=localhost
          zk_server_port=2181
          listen_ip_addr=0.0.0.0
          listen_port=5998
          log_local=True
          log_file=/var/log/contrail/discovery.log
          log_level=SYS_DEBUG
          log_local=1
          cassandra_server_list = localhost:9160
          # minimim time to allow client to cache service information (seconds)
          ttl_min=300
          # maximum time to allow client to cache service information (seconds)
          ttl_max=1800

          # health check ping interval <=0 for disabling
          hc_interval=5

          # maximum hearbeats to miss before server will declare publisher out of
          # service.
          hc_max_miss=3

          # use short TTL for agressive rescheduling if all services are not up
          ttl_short=1

          [DNS-SERVER]
          policy=fixed
        '';
      };
      control = pkgs.writeTextFile {
        name = "contrail-control.conf";
        text = ''
          [DEFAULT]
          log_file = /var/log/contrail/control.log
          log_local = 1
          log_level = SYS_DEBUG

          [IFMAP]
          server_url= https://127.0.0.1:8443
          password = api-server
          user = api-server

          [DISCOVERY]
          port = 5998
          server = 127.0.0.1
        '';
      };
      collector = pkgs.writeTextFile {
        name = "contrail-collector.conf";
        text = ''
          [DEFAULT]
          log_local = 1
          log_level = SYS_DEBUG
          log_file=/var/log/contrail/contrail-collector.log
          cassandra_server_list = 127.0.0.1:9042

          [COLLECTOR]
          port=8086
          server=0.0.0.0

          [DISCOVERY]
          port = 5998
          server = 127.0.0.1

          [REDIS]
          port=6379
          server=127.0.0.1

          [API_SERVER]
          api_server_list = 127.0.0.1:8082
        '';
      };
    in
    { 
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      users.extraUsers.root.password = "root";

      services.rabbitmq.enable = true;
      services.zookeeper.enable = true;
      services.redis.enable = true;

      virtualisation = { memorySize = 4096; cores = 2; };

      # Required by the test suite
      environment.systemPackages = [ pkgs.jq ];

      systemd.services.contrailDiscovery = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service"
          # Keyspaces are created by the contrail-api...
          "contrailApi.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.contrailDiscovery}/bin/contrail-discovery --conf_file ${discovery}";
        path = [ pkgs.netcat ];
        postStart = ''
          sleep 2
          while ! nc -vz localhost 5998; do
            sleep 2
          done
          sleep 2
        '';
      };

      systemd.services.contrailApi = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.contrailApi}/bin/contrail-api --conf_file ${api}";
        path = [ pkgs.netcat ];
        postStart = ''
          sleep 2
          while ! nc -vz localhost 8082; do
            sleep 2
          done
          sleep 2
        '';
      };

      systemd.services.contrailCollector = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service" "redis.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.contrailCollector}/bin/contrail-collector --conf_file ${collector}";
      };

      systemd.services.contrailControl = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "contrailApi.service" "contrailCollector" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.contrailControl}/bin/contrail-control --conf_file ${control}";
	postStart = ''
	  ${contrailPkgs.contrailConfigUtils}/bin/provision_control.py --api_server_ip 127.0.0.1 --api_server_port 8082   --oper add --host_name machine --host_ip 127.0.0.1 --router_asn 64512
	'';
      };

      systemd.services.cassandra = {
         wantedBy = [ "multi-user.target" ];
         after = [ "network.target" ];
         environment = {
           CASSANDRA_CONFIG = cassandraConfigDir;
         };
         script = ''
           mkdir -p /tmp/cassandra-data/
           chmod a+w /tmp/cassandra-data
           export CASSANDRA_CONF=${cassandraConfigDir}
           export JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.port=7199" 
           export JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false" 
           export JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false" 
           ${cassandraPkg}/bin/cassandra -f
         '';
         postStart = ''
           sleep 2
           while ! ${cassandraPkg}/bin/nodetool status >/dev/null 2>&1; do
             sleep 2
           done
         '';
      };
    };

  testScript =
    ''
    $machine->waitForUnit("cassandra.service");
    $machine->waitForUnit("rabbitmq.service");
    $machine->waitForUnit("zookeeper.service");
    $machine->waitForUnit("redis.service");

    $machine->waitForUnit("contrailDiscovery.service");
    $machine->waitForUnit("contrailApi.service");

    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q IfmapServer");
    $machine->succeed("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q ApiServer");

    $machine->waitForUnit("contrailCollector.service");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q Collector");
    $machine->succeed("curl localhost:5998/services.json | jq '.services | map(select(.ep_type == \"Collector\")) | .[].status' | grep -q up");

    $machine->waitForUnit("contrailControl.service");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q xmpp-server");
    $machine->succeed("curl localhost:5998/services.json | jq '.services | map(select(.ep_type == \"xmpp-server\")) | .[].status' | grep -q up");
    '';
}
