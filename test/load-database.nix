{ pkgs
, pkgs_path ? <nixpkgs>
, contrailPkgs
, stdenv
}:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  apiConf = import ./configuration/R3.2/api.nix { inherit pkgs; };
  schemaTransformerConf = import ./configuration/R3.2/schema-transformer.nix { inherit pkgs; };

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
    imports = [
      ../modules/contrail-database-loader.nix
      ../modules/contrail-api.nix
      ../modules/contrail-schema-transformer.nix
    ];
    config = {
      _module.args = { inherit contrailPkgs; };

      contrail.databaseLoader = {
        enable = true;
        cassandraDumpPath = dump;
      };

      contrail.api = {
        enable = true;
        configFile = apiConf;
        waitFor = false;
      };

      contrail.schemaTransformer = {
        enable = true;
        configFile = schemaTransformerConf;
      };

    };
  };

  testScript = ''
    $machine->waitForOpenPort(8082);
    $machine->waitUntilSucceeds("${contrailPkgs.tools.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l virtual-network | grep -q vn1");
  '';

in
  makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; inherit testScript; }
