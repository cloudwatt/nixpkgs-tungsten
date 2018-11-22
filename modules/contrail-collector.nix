{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.collector;
  confFile =
    if contrailPkgs.isContrail32 then
      import ../test/configuration/R3.2/collector.nix { inherit pkgs cfg; }
    else
      import ../test/configuration/master/collector.nix { inherit pkgs cfg; };

in {

  options = {
    contrail.collector = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail collector configuration file";
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
