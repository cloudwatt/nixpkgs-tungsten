{ contrailPkgs, pkgs_path, isContrailMaster, isContrail32 }:

with import (pkgs_path + "/nixos/lib/testing.nix") { system = builtins.currentSystem; };

let
  computeNode = { pkgs, lib, config, ... }: {
    imports = [ ../modules/compute-node.nix ];
    config = {
      _module.args = { inherit contrailPkgs isContrailMaster isContrail32; };

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
{ computeNode = (makeTest { name = "compute-node"; machine = computeNode; testScript = ""; }).driver;
}


