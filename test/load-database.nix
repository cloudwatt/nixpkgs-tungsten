{ pkgs
, pkgs_path ? <nixpkgs>
, contrailPkgs
}:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  api = import ./configuration/R3.2/api.nix { inherit pkgs; };
  schemaTransformer = import ./configuration/R3.2/schema-transformer.nix { inherit pkgs; };

  dump = pkgs.runCommand  "cassandra-dump" {} ''
    mkdir $out
    tar -C $out -xf ${./cassandra-dump.tgz}
  '';

  machine = {pkgs, config, ...}: {
    imports = [ ../modules/contrail-database-loader.nix ];
    config = {
      _module.args = { inherit contrailPkgs; };

      contrail.databaseLoader = {
        cassandraDumpPath = dump;
        enable = true;

        apiConfigFile = api;
        schemaTransformerConfigFile = schemaTransformer;
      };
    };
  };

  testScript = ''
    $machine->waitUntilSucceeds("${contrailPkgs.tools.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l virtual-network | grep -q default-domain:default-project:vn1");
    $machine->succeed("${contrailPkgs.tools.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l virtual-machine-interface  | grep -q default-domain:default-project:machine-vm1-veth0");
  '';

in
  makeTest { name = "load-database"; nodes = { inherit machine; }; inherit testScript; }
