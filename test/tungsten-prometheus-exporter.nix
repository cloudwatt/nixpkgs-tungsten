{ pkgs, stdenv, contrailPkgs }:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  configFile = pkgs.writeTextFile {
    name = "config.yaml";
    text = ''
      analytics:
        host: http://localhost:8081
      logging:
        level: DEBUG
      metrics:
        - name: config_state
          type: Enum
          kwargs: {states: [Functional, Non-Functional]}
          uve_type: config-node
          uve_module: NodeStatus
          json_path: process_status[0].state
          append_field_name: false
    '';
  };

  machine = { config, lib, ... }: {
    imports = [
      ../modules/contrail-api.nix
      ../modules/contrail-analytics-api.nix
      ../modules/contrail-collector.nix
      ../modules/contrail-discovery.nix
    ];
    config = {
      _module.args = { inherit pkgs contrailPkgs; };

      virtualisation = { memorySize = 2042; cores = 2; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.users.root.password = "";

      contrail = {
        api.enable = true;
        discovery.enable = contrailPkgs.isContrail32;
        analyticsApi.enable = true;
        collector.enable = true;
      };

      systemd.services.tungsten-prometheus-exporter = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "contrail-analytics-api.service" ];
        path = [ pkgs.netcat ];
        serviceConfig.ExecStart =
          "${pkgs.tungstenPrometheusExporter}/bin/tungsten-prometheus-exporter --config ${configFile}";
        preStart = ''
          sleep 2
          while ! nc -vz localhost 8081; do
            sleep 2
          done
        '';
      };
    };
  };

  testScript = ''
    $machine->waitForOpenPort(8080);
    $machine->waitUntilSucceeds("curl -s http://localhost:8080 | grep 'tungsten_config_state=\"Functional\"} 1.0'");
  '';

in
  makeTest { name = "tungsten-prometheus-exporter"; nodes = { inherit machine; }; inherit testScript; }
