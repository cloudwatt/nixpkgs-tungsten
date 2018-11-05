{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.allInOne;
in
    let
      svcMonitor = pkgs.writeTextFile {
        name = "contrail-svc-monitor.conf";
        text = ''
          [DEFAULTS]
          rabbit_port = 5672
          rabbit_server = localhost

          log_file = /var/log/contrail/svc-monitor.log
          log_level = SYS_DEBUG
          log_local = 1

          zk_server_port = 2181
          zk_server_ip = 127.0.0.1
          cassandra_server_list = 127.0.0.1:9160
          collectors = 127.0.0.1:8086
          api_server_port = 8082
          api_server_ip = 127.0.0.1
          disc_server_port = 5998
          disc_server_ip = 127.0.0.1
          sandesh_send_rate_limit = 1000
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
      control32 = import ../test/configuration/R3.2/control.nix { inherit pkgs; };
      controlMaster = import ../test/configuration/master/control.nix { inherit pkgs; };
      control = if contrailPkgs.isContrail32 then control32 else controlMaster;

      collector32 = import ../test/configuration/R3.2/control.nix { inherit pkgs; };
      collectorMaster = import ../test/configuration/master/control.nix { inherit pkgs; };
      collector = if contrailPkgs.isContrail32 then collector32 else collectorMaster;

      api = import ../test/configuration/R3.2/api.nix { inherit pkgs; };
      schema = import ../test/configuration/R3.2/schema-transformer.nix { inherit pkgs; };

    in {
      options = {
        contrail.allInOne = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          vhostInterface = mkOption {
            type = types.str;
            default = "eth1";
            description = "Physical interface name to which virtual host interface maps to";
          };
          vhostIP = mkOption {
            type = types.str;
            default = "192.168.1.1";
          };
        };
      };

      imports = [ ./compute-node.nix
                  ./cassandra.nix
                  ./contrail-api.nix
                  ./contrail-schema-transformer.nix
                  ./contrail-discovery.nix ];

      config = rec {
        services.rabbitmq.enable = true;
        services.zookeeper.enable = true;
        services.redis.enable = true;
        cassandra.enable = true;

        contrail.vrouterAgent = {
          enable = true;
          vhostInterface = cfg.vhostInterface;
          vhostIP = cfg.vhostIP;
        };

        contrail.discovery = {
          enable = contrailPkgs.isContrail32;
          configFile = discovery;
        };

        contrail.api = {
          enable = true;
          configFile = api;
        };

        contrail.schemaTransformer = {
          enable = true;
          configFile = schema;
        };

        systemd.services.contrail-svc-monitor = {
          wantedBy = [ "multi-user.target" ];
          after = [ "contrail-api.service" ];
          script = "${contrailPkgs.svcMonitor}/bin/contrail-svc-monitor --conf_file ${svcMonitor}";
          path = [ pkgs.netcat ];
          postStart = ''
            sleep 2
            while ! nc -vz localhost 8088; do
              sleep 2
            done
            sleep 2
          '';
        };

        systemd.services.contrail-query-engine = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service" "redis.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${contrailPkgs.queryEngine}/bin/qed --conf_file ${query-engine}";
        };

        systemd.services.contrail-collector = {
          wantedBy = [ "network-online.target" ];
          after = [ "contrail-query-engine.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${contrailPkgs.collector}/bin/contrail-collector --conf_file ${collector}";
        };

        systemd.services.contrail-analytics-api = {
          wantedBy = [ "multi-user.target" ];
          requires = [ "redis.service" ];
          after = [ "contrail-collector.service" ];
          preStart = "mkdir -p /var/log/contrail/ && ${pkgs.redis}/bin/redis-cli config set protected-mode no";
          script = "${contrailPkgs.analyticsApi}/bin/contrail-analytics-api --conf_file ${analytics}";
        };

        systemd.services.contrail-control = {
          wantedBy = [ "multi-user.target" ];
          after = [ "contrail-api.service" "contrail-collector.service" ];
          preStart = "mkdir -p /var/log/contrail/";
          script = "${contrailPkgs.control}/bin/contrail-control --conf_file ${control}";
          postStart = ''
            ${contrailPkgs.configUtils}/bin/provision_control.py --api_server_ip 127.0.0.1 --api_server_port 8082   --oper add --host_name machine --host_ip 127.0.0.1 --router_asn 64512
          '';
        };

     };
  }
