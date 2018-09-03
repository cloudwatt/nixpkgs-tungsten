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
    };
  };

  config = mkIf cfg.enable {
    systemd.services.contrail-discovery = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "cassandra.service" "rabbitmq.servive" "zookeeper.service"
                # Keyspaces are created by the contrail-api...
                "contrail-api.service" ];
      preStart = "mkdir -p /var/log/contrail/";
      script = "${contrailPkgs.discovery}/bin/contrail-discovery --conf_file ${cfg.configFile}";
      path = [ pkgs.netcat ];
      postStart = ''
        sleep 2
        while ! nc -vz localhost 5998; do
          sleep 2
        done
        sleep 2
      '';
    };
  };
}
