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
      webuiPkgs = import ../webui.nix { inherit pkgs; };
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
      web-server = pkgs.writeTextFile {
        name = "contrail-web-server.js";
        text = ''
          var config = {};
          config.staticAuth = [
            {"username": "admin", "password": "admin"}
          ];
          config.multi_tenancy = {};
          config.multi_tenancy.enabled = false;
          config.orchestration = {};
          config.orchestration.Manager = 'none';
          config.serviceEndPointFromConfig = true;
          config.endpoints = {};
          config.endpoints.apiServiceType = 'ApiServer';
          config.endpoints.opServiceType = 'OpServer';
          config.regionsFromConfig = true;
          config.regions = {};
          config.regions.RegionOne = 'http://127.0.0.1:5000/v2.0';
          config.serviceEndPointTakePublicURL = true;
          config.networkManager = {};
          config.networkManager.ip = '127.0.0.1';
          config.networkManager.port = '9696'
          config.networkManager.authProtocol = 'http';
          config.networkManager.apiVersion = [];
          config.networkManager.strictSSL = false;
          config.networkManager.ca = "";
          config.imageManager = {};
          config.imageManager.ip = '127.0.0.1';
          config.imageManager.port = '9292';
          config.imageManager.authProtocol = 'http';
          config.imageManager.apiVersion = ['v1', 'v2'];
          config.imageManager.strictSSL = false;
          config.imageManager.ca = "";
          config.computeManager = {};
          config.computeManager.ip = '127.0.0.1';
          config.computeManager.port = '8774';
          config.computeManager.authProtocol = 'http';
          config.computeManager.apiVersion = ['v1.1', 'v2'];
          config.computeManager.strictSSL = false;
          config.computeManager.ca = "";
          config.identityManager = {};
          config.identityManager.ip = '127.0.0.1';
          config.identityManager.port = '5000';
          config.identityManager.authProtocol = 'http';
          config.identityManager.apiVersion = ['v2.0'];
          config.identityManager.strictSSL = false;
          config.identityManager.ca = "";
          config.storageManager = {};
          config.storageManager.ip = '127.0.0.1';
          config.storageManager.port = '8776';
          config.storageManager.authProtocol = 'http';
          config.storageManager.apiVersion = ['v1'];
          config.storageManager.strictSSL = false;
          config.storageManager.ca = "";
          config.cnfg = {};
          config.cnfg.server_ip = '127.0.0.1';
          config.cnfg.server_port = '8082';
          config.cnfg.authProtocol = 'http';
          config.cnfg.strictSSL = false;
          config.cnfg.ca = "";
          config.analytics = {};
          config.analytics.server_ip = '127.0.0.1';
          config.analytics.server_port = '8081';
          config.analytics.authProtocol = 'http';
          config.analytics.strictSSL = false;
          config.analytics.ca = "";
          config.vcenter = {};
          config.vcenter.server_ip = '127.0.0.1';         //vCenter IP
          config.vcenter.server_port = '443';             //Port
          config.vcenter.authProtocol = 'https';          //http or https
          config.vcenter.datacenter = 'vcenter';          //datacenter name
          config.vcenter.dvsswitch = 'vswitch';           //dvsswitch name
          config.vcenter.strictSSL = false;               //Validate the certificate or ignore
          config.vcenter.ca = "";                         //specify the certificate key file
          config.vcenter.wsdl = '${webuiPkgs.webCore}/webroot/js/vim.wsdl';
          config.discoveryService = {};
          config.discoveryService.server_port = '5998';
          config.discoveryService.enable = true;
          config.jobServer = {};
          config.jobServer.server_ip = '127.0.0.1';
          config.jobServer.server_port = '3000';
          config.files = {};
          config.files.download_path = '/tmp';
          config.cassandra = {};
          config.cassandra.server_ips = ['127.0.0.1'];
          config.cassandra.server_port = '9042';
          config.cassandra.enable_edit = false;
          config.kue = {};
          config.kue.ui_port = '3002'
          config.webui_addresses = ['0.0.0.0'];
          config.insecure_access = false;
          config.http_port = '8080';
          config.https_port = '8143';
          config.require_auth = false;
          config.node_worker_count = 1;
          config.maxActiveJobs = 10;
          config.redisDBIndex = 3;
          config.redis_server_port = '6379';
          config.redis_server_ip = '127.0.0.1';
          config.redis_dump_file = '/var/lib/redis/dump-webui.rdb';
          config.redis_password = "";
          config.logo_file = '${webuiPkgs.webCore}/webroot/img/opencontrail-logo.png';
          config.favicon_file = '${webuiPkgs.webCore}/webroot/img/opencontrail-favicon.ico';
          config.featurePkg = {};
          config.featurePkg.webController = {};
          config.featurePkg.webController.path = '${webuiPkgs.webController}';
          config.featurePkg.webController.enable = true;
          config.qe = {};
          config.qe.enable_stat_queries = false;
          config.logs = {};
          config.logs.level = 'debug';
          config.getDomainProjectsFromApiServer = false;
          config.network = {};
          config.network.L2_enable = false;
          config.getDomainsFromApiServer = true;
          config.jsonSchemaPath = "${webuiPkgs.webCore}/src/serverroot/configJsonSchemas";
          module.exports = config;
        '';
      };
    in {
      imports = [ ./compute-node.nix ];
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
          controllerPkgs.contrailVrouterPortControl controllerPkgs.contrailVrouterUtils controllerPkgs.contrailConfigUtils
          contrailCreateNetwork controllerPkgs.contrailVrouterNetns
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

        systemd.services.contrailJobServer = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "contrailDiscovery.service" ];
          serviceConfig.WorkingDirectory = "${webuiPkgs.webCore}";
          preStart = ''
            cp ${web-server} /tmp/contrail-web-core-config.js
          '';
          script = "${pkgs.nodejs-4_x}/bin/node ${webuiPkgs.webCore}/jobServerStart.js";
        };

        systemd.services.contrailWebServer = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "contrailJobServer.service" "contrailAnalyticsApi.service" ];
          serviceConfig.WorkingDirectory = "${webuiPkgs.webCore}";
          script = "${pkgs.nodejs-4_x}/bin/node ${webuiPkgs.webCore}/webServerStart.js";
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
