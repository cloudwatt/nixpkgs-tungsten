{ pkgs
, pkgs_path ? <nixpkgs>
, contrailPkgs
, stdenv
}:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  api = import ./configuration/R3.2/api.nix { inherit pkgs; };

  schemaTransformer = import ./configuration/R3.2/schema-transformer.nix { inherit pkgs; };

  dump = stdenv.mkDerivation {
    name = "cassandra-dump";
    src = ./cassandra-dump.tgz;
    setSourceRoot = "sourceRoot=`pwd`";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

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
    $machine->waitForOpenPort(8082);
    $machine->waitUntilSucceeds("${contrailPkgs.tools.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l virtual-network | grep -q vn1");
  '';

in
  makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; inherit testScript; }
