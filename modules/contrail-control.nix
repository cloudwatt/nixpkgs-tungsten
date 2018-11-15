{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.control;
in {
  options = {
    contrail.control = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail control configuration file";
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.contrail-control = mkMerge [
      {
        after = [ "network.target" "contrail-api.service" "contrail-collector.service" ];
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.control}/bin/contrail-control --conf_file ${cfg.configFile}";
        postStart = ''
          ${contrailPkgs.configUtils}/bin/provision_control.py --api_server_ip 127.0.0.1 \
            --api_server_port 8082  --oper add --host_name $HOSTNAME --host_ip 127.0.0.1 --router_asn 64512
        '';
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
