{ contrailPkgs, pkgs }:

let p = import ./requirements.nix { inherit contrailPkgs pkgs; };
in p.packages."contrail-api-cli-with-extra"
