{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.allInOne;
in
    let

      control32 = import ../test/configuration/R3.2/control.nix { inherit pkgs; };
      controlMaster = import ../test/configuration/master/control.nix { inherit pkgs; };
      controlConf = if contrailPkgs.isContrail32 then control32 else controlMaster;

      collector32 = import ../test/configuration/R3.2/control.nix { inherit pkgs; };
      collectorMaster = import ../test/configuration/master/control.nix { inherit pkgs; };
      collectorConf = if contrailPkgs.isContrail32 then collector32 else collectorMaster;

      discoveryConf = import ../test/configuration/R3.2/discovery.nix { inherit pkgs; };
      apiServerConf = import ../test/configuration/R3.2/api.nix { inherit pkgs; };
      schemaTransformerConf = import ../test/configuration/R3.2/schema-transformer.nix { inherit pkgs; };
      svcMonitorConf = import ../test/configuration/R3.2/svc-monitor.nix { inherit pkgs; };

      analyticsApiConf = import ../test/configuration/R3.2/analytics-api.nix { inherit pkgs; };
      queryEngineConf = import ../test/configuration/R3.2/query-engine.nix { inherit pkgs; };

    in {

      options = {
        contrail.allInOne = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          vhostInterface = mkOption {
            type = types.str;
            default = "eth1";
            description = "Physical interface name to which virtual host interface maps to";
          };
          vhostIP = mkOption {
            type = types.str;
            default = "192.168.1.1";
          };
        };
      };

      imports = [
        ./cassandra.nix
        ./contrail-vrouter-agent.nix
        ./contrail-api.nix
        ./contrail-schema-transformer.nix
        ./contrail-svc-monitor.nix
        ./contrail-discovery.nix
        ./contrail-analytics-api.nix
        ./contrail-query-engine.nix
        ./contrail-collector.nix
        ./contrail-control.nix
      ];

      config = rec {

        networking.firewall.enable = false;

        services.openssh.enable = true;
        services.openssh.permitRootLogin = "yes";
        services.openssh.extraConfig = "PermitEmptyPasswords yes";
        users.extraUsers.root.password = "";

        services.rabbitmq = {
          enable = true;
          # allow to connect from outside the VM
          config = ''
            [{rabbit, [{loopback_users, []}]}].
          '';
        };
        services.zookeeper.enable = true;
        cassandra.enable = true;

        environment.systemPackages = with pkgs; [
          contrailApiCliWithExtra
        ];

        contrail = {
          vrouterAgent = {
            enable = true;
            vhostInterface = cfg.vhostInterface;
            vhostIP = cfg.vhostIP;
          };
          discovery = {
            enable = contrailPkgs.isContrail32;
            configFile = discoveryConf;
          };
          api = {
            enable = true;
            configFile = apiServerConf;
          };
          schemaTransformer = {
            enable = true;
            configFile = schemaTransformerConf;
          };
          svcMonitor = {
            enable = true;
            configFile = svcMonitorConf;
          };
          analyticsApi = {
            enable = true;
            configFile = analyticsApiConf;
          };
          queryEngine = {
            enable = true;
            configFile = queryEngineConf;
          };
          collector = {
            enable = true;
            configFile = collectorConf;
          };
          control = {
            enable = true;
            configFile = controlConf;
          };
        };

     };
  }
