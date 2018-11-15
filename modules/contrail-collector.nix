{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.collector;
in {
  options = {
    contrail.collector = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail query-engine configuration file";
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    services.redis.enable = true;
    systemd.services.contrail-collector = mkMerge [
      {
        after = [ "network.target" ] ++ (optional contrailPkgs.isContrail32 "contrail-discovery.service");
        preStart = "mkdir -p /var/log/contrail/";
        script = "${contrailPkgs.collector}/bin/contrail-collector --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };

}
