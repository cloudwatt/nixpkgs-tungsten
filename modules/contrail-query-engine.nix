{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.queryEngine;
  confFile = import ./configuration/R3.2/query-engine.nix { inherit pkgs cfg; };

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
        default = confFile;
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_WARN";
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
