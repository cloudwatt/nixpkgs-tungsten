{ pkgs }:

let p = import ./requirements.nix { inherit pkgs; };
in p.packages."contrail-api-cli-with-extra"
