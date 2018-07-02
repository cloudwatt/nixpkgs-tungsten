{ pkgs
, pkgs_path ? <nixpkgs>
, contrailPkgs
}:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  api = import ./configuration/R3.2/api.nix { inherit pkgs; };
  schemaTransformer = import ./configuration/R3.2/schema-transformer.nix { inherit pkgs; };
  dump = fetchzip {
    name = "cassandra-dump";
    src = ./dump.tgz;
  }

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
    $machine->waitUntilSucceeds("${contrailApiCliWithExtra}/bin/contrail-api-cli ls virtual-network | grep -q vn1");
  ''
  
in
  vm = (makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; inherit testScript; });
