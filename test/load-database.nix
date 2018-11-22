{ pkgs
, stdenv
, contrailPkgs
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  dump = stdenv.mkDerivation {
    name = "cassandra-dump";
    src = ./cassandra-dump.tgz;
    setSourceRoot = "sourceRoot=`pwd`";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

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

      contrail.databaseLoader = {
        enable = true;
        cassandraDumpPath = dump;
      };

      contrail.api.enable = true;
      contrail.schemaTransformer.enable = true;

    };
  };

  testScript = ''
    $machine->waitForOpenPort(8082);
    $machine->waitUntilSucceeds("${pkgs.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l virtual-network | grep -q vn1");
    $machine->succeed("${pkgs.contrailApiCliWithExtra}/bin/contrail-api-cli --ns contrail_api_cli.provision add-vn --project-fqname default-domain:default-project testvn2");
    $machine->succeed("${pkgs.contrailApiCliWithExtra}/bin/contrail-api-cli ls -l routing-instance | grep -q default-domain:default-project:testvn2:testvn2");
    $machine->succeed("${pkgs.contrailApiCliWithExtra}/bin/contrail-api-cli cat routing-instance/default-domain:default-project:testvn2:testvn2 | grep -q route-target");
  '';

in
  makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; inherit testScript; }
