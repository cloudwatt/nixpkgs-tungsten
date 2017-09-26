{ pkgs_path }:

with import (pkgs_path + "/nixos/lib/testing.nix") { system = builtins.currentSystem; };

let
  computeNode = { pkgs, lib, config, ... }: {
    imports = [ ../modules/compute-node.nix ];
    config = {
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      users.extraUsers.root.password = "root";
      virtualisation.graphics = false;

      contrail.vrouterAgent = {
        enable = true;
        provisionning = false;
        collectorHost = "172.16.42.42";
        discoveryHost = "172.16.42.42";
        controlHost = "172.16.42.42";
      };
    };
  };
in
{ computeNode = (makeTest { name = "computeNode"; machine = computeNode; testScript = ""; }).driver;
}


