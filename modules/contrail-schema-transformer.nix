{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.schemaTransformer;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/schema-transformer.nix") { inherit pkgs cfg; };

in {

  options = {
    contrail.schemaTransformer = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "schema transformer configuration file";
        default = confFile;
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_INFO";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.contrail-schema-transformer = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "rabbitmq.service"
                  "zookeeper.service" "contrail-api.service" ];
        requires = [ "contrail-api.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        serviceConfig.ExecStart =
          "${contrailPkgs.schemaTransformer}/bin/contrail-schema --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
