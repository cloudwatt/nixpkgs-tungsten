{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.schemaTransformer;
in {
  options = {
    contrail.schemaTransformer = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "The contrail schema transformer file path";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.contrail-schema-transformer = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service" ];
      preStart = "mkdir -p /var/log/contrail/";
      script = "${contrailPkgs.schemaTransformer}/bin/contrail-schema --conf_file ${cfg.configFile}";
    };
  };
}

