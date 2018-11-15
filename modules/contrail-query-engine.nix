{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.queryEngine;
in {
  options = {
    contrail.queryEngine = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail query-engine configuration file";
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    services.redis.enable = true;
    systemd.services.contrail-query-engine = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "contrail-discovery.service"
                  "rabbitmq.service" "zookeeper.service" "redis.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.queryEngine}/bin/qed --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
