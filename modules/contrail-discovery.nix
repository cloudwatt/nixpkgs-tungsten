{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  # We should try a nixpkgs overlay to avoid this explicit import
  cfg = config.contrail.discovery;
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
