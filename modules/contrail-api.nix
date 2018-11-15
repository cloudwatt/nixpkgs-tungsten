{ config
, lib
, pkgs
, contrailPkgs
, ... }:

with lib;

let
  cfg = config.contrail.api;
in {
  options = {
    contrail.api = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail-api configuration file";
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      waitFor = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to wait for the API port in the post start phase
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.zookeeper.enable = true;
    services.rabbitmq = {
      enable = true;
      listenAddress = "0.0.0.0";
    };
    systemd.services.contrail-api = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "rabbitmq.service" "zookeeper.service" ];
        requires = [ "cassandra.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.apiServer}/bin/contrail-api --conf_file  ${cfg.configFile}";
        path = [ pkgs.netcat ];
        postStart = lib.optionalString cfg.waitFor ''
          sleep 2
          while ! nc -vz localhost 8082; do
            sleep 2
          done
          sleep 2
        '';
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };
}

