{ config
, lib
, pkgs
, contrailPkgs
, ...
}:

with lib;

let

  cfg = config.contrail.api;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/api.nix") { inherit pkgs cfg; };

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
          Whether to wait for the API port in the post start phase
        '';
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_INFO";
      };
    };
  };

  config = mkIf cfg.enable {
    cassandra.enable = true;
    services.zookeeper.enable = true;
    services.rabbitmq = {
      enable = true;
      listenAddress = "0.0.0.0";
      # allow to connect from outside the VM
      config = ''
        [{rabbit, [{loopback_users, []}]}].
      '';
    };
    systemd.services.contrail-api = mkMerge [
      {
        after = [ "network.target" "cassandra.service" "rabbitmq.service" "zookeeper.service" ];
        requires = [ "cassandra.service" "zookeeper.service" ];
        path = [ pkgs.netcat ];
        preStart = "mkdir -p /var/log/contrail/";
        serviceConfig.ExecStart = "${contrailPkgs.apiServer}/bin/contrail-api --conf_file ${cfg.configFile}";
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

