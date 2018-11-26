{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.queryEngine;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/query-engine.nix") { inherit pkgs cfg; };

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
        after = [
          "network.target" "cassandra.service" "rabbitmq.service" "zookeeper.service" "redis.service"
        ] ++ optionals contrailPkgs.isContrail32 [
          "contrail-discovery.service"
        ];
        preStart = "mkdir -p /var/log/contrail/";
        serviceConfig.ExecStart =
          "${contrailPkgs.queryEngine}/bin/contrail-query-engine --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
