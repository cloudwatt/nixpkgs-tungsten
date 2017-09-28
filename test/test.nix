{ pkgs
# I didn't find a better way to run test by using the test framework
# of the bootstrapped nixpkgs. In fact, this is to avoid the user to
# set a specific NIX_PATH env var.
, pkgs_path ? <nixpkgs> }:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  machine = {pkgs, config, ...}:
    let
      controllerPkgs = import ../controller.nix { inherit pkgs; };
      contrailDeps = import ../deps.nix { inherit pkgs; };

      contrailCreateNetwork = pkgs.stdenv.mkDerivation rec {
        name = "contrail-create-network";
        src = ./contrail-create-network.py;
        phases = [ "installPhase" "fixupPhase" ];
        buildInputs = [
          (pkgs.python27.withPackages (pythonPackages: with pythonPackages; [
          controllerPkgs.vnc_api controllerPkgs.cfgm_common ]))
        ];
        installPhase = ''
          mkdir -p $out/bin
          cp ${src} $out/bin/contrail-create-network.py
        '';
      };

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

        cat >> $out/logback.xml << EOF
        <configuration scan="true">
          <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
            <file>/var/log/cassandra/system.log</file>
            <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
              <fileNamePattern>/var/log/cassandra/system.log.%i.zip</fileNamePattern>
              <minIndex>1</minIndex>
              <maxIndex>20</maxIndex>
            </rollingPolicy>

            <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
              <maxFileSize>20MB</maxFileSize>
            </triggeringPolicy>
            <encoder>
              <pattern>%-5level [%thread] %date{ISO8601} %F:%L - %msg%n</pattern>
              <!-- old-style log format
              <pattern>%5level [%thread] %date{ISO8601} %F (line %L) %msg%n</pattern>
              -->
            </encoder>
          </appender>

          <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
            <encoder>
              <pattern>%-5level %date{HH:mm:ss,SSS} %msg%n</pattern>
            </encoder>
          </appender>

          <root level="INFO">
            <appender-ref ref="FILE" />
            <appender-ref ref="STDOUT" />
          </root>

          <logger name="com.thinkaurelius.thrift" level="ERROR"/>
        </configuration>
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
        text = ''
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
      query-engine = pkgs.writeTextFile {
        name = "contrail-query-engine.conf";
        text = ''
          [DEFAULT]
          log_file = /var/log/contrail/query-engine.log
          log_level = SYS_DEBUG
          log_local = 1
          cassandra_server_list = 127.0.0.1:9042

          [DISCOVERY]
          server = 127.0.0.1
          port = 5998

          [REDIS]
          server = 127.0.0.1
          port = 6379
        '';
      };
      analytics = pkgs.writeTextFile {
        name = "contrail-analytics-api.conf";
        text = ''
          [DEFAULTS]
          cassandra_server_list = 127.0.0.1:9042
          collectors = 127.0.0.1:8086

          aaa_mode = no-auth
          partitions = 0

          log_file = /var/log/contrail/analytic-api.log
          log_level = SYS_DEBUG
          log_local = 1

          [DISCOVERY]
          disc_server_ip = 127.0.0.1
          disc_server_port = 5998

          [REDIS]
          server = 127.0.0.1
          redis_server_port = 6379
          redis_query_port = 6379
        '';
      };
      collector = pkgs.writeTextFile {
        name = "contrail-collector.conf";
        text = ''
          [DEFAULT]
          log_local = 1
          log_level = SYS_DEBUG
          log_file = /var/log/contrail/contrail-collector.log
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
    in {
      imports = [ ../modules/compute-node.nix ];
      config = rec {
        services.openssh.enable = true;
        services.openssh.permitRootLogin = "yes";
        users.extraUsers.root.password = "root";

        services.rabbitmq.enable = true;
        services.zookeeper.enable = true;
        services.redis.enable = true;

        virtualisation = { memorySize = 4096; cores = 2; };

        # Required by the test suite
        environment.systemPackages = [
          pkgs.jq # contrailDeps.contrailApiCli
          controllerPkgs.contrailConfigUtils
          contrailCreateNetwork
        ];

        contrail.vrouterAgent.enable = true;

        systemd.services.contrailDiscovery = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service"
                  # Keyspaces are created by the contrail-api...
                  "contrailApi.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${controllerPkgs.contrailDiscovery}/bin/contrail-discovery --conf_file ${discovery}";
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
          script = "${controllerPkgs.contrailApi}/bin/contrail-api --conf_file ${api}";
          path = [ pkgs.netcat ];
          postStart = ''
            sleep 2
            while ! nc -vz localhost 8082; do
              sleep 2
            done
            sleep 2
          '';
        };

        systemd.services.contrailQueryEngine = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service" "redis.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${controllerPkgs.contrailQueryEngine}/bin/qed --conf_file ${query-engine}";
        };

        systemd.services.contrailCollector = {
          wantedBy = [ "multi-user.target" ];
          after = [ "contrailQueryEngine.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${controllerPkgs.contrailCollector}/bin/contrail-collector --conf_file ${collector}";
        };

        systemd.services.contrailAnalyticsApi = {
          wantedBy = [ "multi-user.target" ];
          after = [ "contrailCollector.service" ];
          preStart = "mkdir -p /var/log/contrail/ && ${pkgs.redis}/bin/redis-cli config set protected-mode no";
          script = "${controllerPkgs.contrailAnalyticsApi}/bin/contrail-analytics-api --conf_file ${analytics}";
        };

        systemd.services.contrailControl = {
          wantedBy = [ "multi-user.target" ];
          after = [ "contrailApi.service" "contrailCollector.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${controllerPkgs.contrailControl}/bin/contrail-control --conf_file ${control}";
          postStart = ''
            ${controllerPkgs.contrailConfigUtils}/bin/provision_control.py --api_server_ip 127.0.0.1 --api_server_port 8082   --oper add --host_name machine --host_ip 127.0.0.1 --router_asn 64512
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
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q ApiServer");

    $machine->waitForUnit("contrailCollector.service");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q Collector");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services | map(select(.ep_type == \"Collector\")) | .[].status' | grep -q up");

    $machine->waitForUnit("contrailControl.service");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services[].ep_type' | grep -q xmpp-server");
    $machine->waitUntilSucceeds("curl localhost:5998/services.json | jq '.services | map(select(.ep_type == \"xmpp-server\")) | .[].status' | grep -q up");

    $machine->succeed("lsmod | grep -q vrouter");
    $machine->waitForUnit("contrailVrouterAgent.service");

    $machine->waitUntilSucceeds("curl http://localhost:8083/Snh_ShowBgpNeighborSummaryReq | grep machine | grep -q Established");

    $machine->succeed("contrail-create-network.py default-domain:default-project:vn1");
    $machine->succeed("netns-daemon-start -n default-domain:default-project:vn1 vm1");
    $machine->succeed("netns-daemon-start -n default-domain:default-project:vn1 vm2");

    $machine->succeed("ip netns exec ns-vm1 ip a | grep -q 20.1.1.252");
    $machine->succeed("ip netns exec ns-vm1 ping -c1 20.1.1.251");

    $machine->waitForUnit("contrailAnalyticsApi.service");
    $machine->waitUntilSucceeds("curl http://localhost:8081/analytics/uves/vrouters | jq '. | length' | grep -q 1");
      
    $machine->waitForUnit("contrailWebServer.service");
    $machine->waitForUnit("contrailJobServer.service");
  '';
in
  makeTest { nodes = { inherit machine; }; testScript = testScript; }
