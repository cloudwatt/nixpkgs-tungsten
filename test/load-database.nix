{ pkgs
, stdenv
, contrailPkgs
, cassandraDumpPath
, extraTestScript ? ""
}:

with import (pkgs.path + /nixos/lib/testing.nix) { inherit pkgs; system = builtins.currentSystem; };

let

  machine = { config, ... }: {
    imports = [
      ../modules/contrail-database-loader.nix
      ../modules/contrail-api.nix
      ../modules/contrail-schema-transformer.nix
    ];
    config = {
      _module.args = { inherit pkgs contrailPkgs; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      environment.systemPackages = with pkgs; [
        contrailApiCliWithExtra
      ];

      contrail.databaseLoader = {
        enable = true;
        inherit cassandraDumpPath;
      };

      contrail.api.enable = true;
      contrail.schemaTransformer.enable = true;

      # Don't timeout when loading big DBs
      systemd.services.contrail-api.serviceConfig.TimeoutStartSec = "infinity";
    };
  };

  testScript = ''
    $machine->waitForUnit("cassandra.service");
    $machine->waitForUnit("contrail-api.service");
    $machine->succeed("contrail-api-cli --ns contrail_api_cli.provision add-vn --project-fqname default-domain:default-project vn2");
    $machine->succeed("contrail-api-cli ls -l routing-instance | grep -q default-domain:default-project:vn2:vn2");
    $machine->waitUntilSucceeds("contrail-api-cli cat routing-instance/default-domain:default-project:vn2:vn2 | grep -q route-target");
  '' + extraTestScript;

in
  makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; inherit testScript; }
