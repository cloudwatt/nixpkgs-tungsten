{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.collector;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/collector.nix") { inherit pkgs cfg; };

in {

  options = {
    contrail.collector = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail collector configuration file";
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
    systemd.services.contrail-collector = mkMerge [
      {
        after = if contrailPkgs.isContrail32
          then [ "network.target" "cassandra.service" "contrail-discovery.service" ]
          else [ "network.target" "cassandra.service" "zookeeper.service" "rabbitmq.service" "redis.service" ];
        requires = if contrailPkgs.isContrail32
          then [ "cassandra.service" "contrail-discovery.service" ]
          else [ "cassandra.service" "zookeeper.service" "rabbitmq.service" "redis.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        serviceConfig.ExecStart = "${contrailPkgs.collector}/bin/contrail-collector --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
