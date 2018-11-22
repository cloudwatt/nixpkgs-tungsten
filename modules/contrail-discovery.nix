{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.discovery;
  confFile = import ../test/configuration/R3.2/discovery.nix { inherit pkgs cfg; };

in {

  options = {
    contrail.discovery = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "The contrail discovery file path";
        default = confFile;
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      waitFor = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to wait for the discovery port in the post start phase
        '';
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_WARN";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.contrail-discovery = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "rabbitmq.service" "zookeeper.service"
                  # Keyspaces are created by the contrail-api...
                  "contrail-api.service" ];
        requires = [ "contrail-api.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.discovery}/bin/contrail-discovery --conf_file ${cfg.configFile}";
        path = [ pkgs.netcat ];
        postStart = optionalString cfg.waitFor ''
          sleep 2
          while ! nc -vz localhost 5998; do
            sleep 2
          done
          sleep 2
        '';
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };
}
