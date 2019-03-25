{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.webui;
  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/webui.nix") { inherit pkgs cfg contrailPkgs; };
in {
  options = {
    contrail.webui = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        description = "contrail webui configuration file";
        default = confFile;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.contrail-job-server = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "contrail-analytics-api.service" "cassandra.service" "contrail-api.service" ];
      after = [ "network.target" "contrail-analytics-api.service" "cassandra.service" "contrail-api.service" ];
      serviceConfig.WorkingDirectory = "${contrailPkgs.webui.webCore}";
      preStart = ''
        cp ${cfg.configFile} /tmp/contrail-web-core-config.js
      '';
      script = "${contrailPkgs.deps.nodejs-4_x}/bin/node ${contrailPkgs.webui.webCore}/jobServerStart.js";
    };

    systemd.services.contrail-web-server = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "contrailJobServer.service" "contrail-analytics-api.service" "cassandra.service" "contrail-api.service" ];
      after = [ "contrailJobServer.service" "network.target" "contrail-analytics-api.service" "cassandra.service" "contrail-api.service" ];
      serviceConfig.WorkingDirectory = "${contrailPkgs.webui.webCore}";
      script = "${contrailPkgs.deps.nodejs-4_x}/bin/node ${contrailPkgs.webui.webCore}/webServerStart.js";
    };
  };
}
