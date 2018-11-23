{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.svcMonitor;
  confFile = import ./configuration/R3.2/svc-monitor.nix { inherit pkgs cfg; };

in {
  options = {
    contrail.svcMonitor = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail svc-monitor configuration file";
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
    systemd.services.contrail-svc-monitor = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "rabbitmq.service"
                  "zookeeper.service" "contrail-api.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.svcMonitor}/bin/contrail-svc-monitor --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };
}
