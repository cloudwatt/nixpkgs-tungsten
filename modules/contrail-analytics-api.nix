{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.analyticsApi;
in {
  options = {
    contrail.analyticsApi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail analytics-api configuration file";
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    services.redis.enable = true;
    systemd.services.contrail-analytics-api = mkMerge [
      {
        requires = [ "redis.service" ];
        after = [ "contrail-collector.service" ];
        preStart = "mkdir -p /var/log/contrail/ && ${pkgs.redis}/bin/redis-cli config set protected-mode no";
        script = "${contrailPkgs.analyticsApi}/bin/contrail-analytics-api --conf_file ${cfg.configFile}";
      }
      (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
    ];
  };
}
