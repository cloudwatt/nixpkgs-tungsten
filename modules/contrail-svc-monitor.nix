{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.svcMonitor;
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
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
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
