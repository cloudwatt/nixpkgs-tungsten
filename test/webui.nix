{ pkgs
# I didn't find a better way to run test by using the test framework
# of the bootstrapped nixpkgs. In fact, this is to avoid the user to
# set a specific NIX_PATH env var.
, pkgs_path ? <nixpkgs> }:

with import (pkgs_path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  machine = {pkgs, config, ...}: {
    imports = [ ../modules/webui.nix ];
    config = rec {
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      users.extraUsers.root.password = "root";

      virtualisation = { memorySize = 1024; cores = 1; };

      contrail.webui.enable = true;
    };
  };
  testScript =
    ''
    $machine->waitForUnit("contrailWebServer.service");
    $machine->waitForUnit("contrailJobServer.service");
  '';
in
  makeTest { name = "webui"; nodes = { inherit machine; }; testScript = testScript; }
