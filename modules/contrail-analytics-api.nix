{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.analyticsApi;
  confFile = import ../test/configuration/R3.2/analytics-api.nix { inherit pkgs cfg; };

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
        default = confFile;
      };
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_WARN";
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
