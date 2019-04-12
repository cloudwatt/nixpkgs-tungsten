{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.alarmGen;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/alarm-gen.nix") { inherit pkgs cfg; };

in {

  options = {
    contrail.alarmGen = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail alarm-gen configuration file";
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

    services.apache-kafka = {
      enable = true;
      extraProperties = ''
        listeners=PLAINTEXT://:9092
        bootstrap.servers=localhost:9092
        offsets.topic.replication.factor=1
      '';
    };

    systemd.services.contrail-alarm-gen = mkMerge [
      {
        after = [ "contrail-analytics-api.service" "contrail-api.service" ];
        preStart = ''
          mkdir -p /var/log/contrail/
        '';
        serviceConfig.ExecStart =
          "${contrailPkgs.analyticsApi}/bin/contrail-alarm-gen --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };
}
