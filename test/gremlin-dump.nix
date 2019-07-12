{ pkgs, stdenv, cassandraDumpPath }:

with import (pkgs.path + /nixos/lib/testing.nix) { inherit pkgs; system = builtins.currentSystem; };

let

  machine = { config, ... }: {
    imports = [
      ../modules/contrail-database-loader.nix
      ../modules/gremlin-server.nix
    ];
    config = {
      _module.args = { inherit pkgs; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      contrail.databaseLoader = {
        enable = true;
        inherit cassandraDumpPath;
      };

      gremlin.server.enable = true;

    };
  };

  testScript = ''
    $machine->waitForOpenPort(8182);
    $machine->succeed("${pkgs.contrailGremlin}/bin/gremlin-send 'g.V().count()'");
  '';

in
  makeTest { name = "gremlin-dump"; nodes = { inherit machine; }; inherit testScript; }
