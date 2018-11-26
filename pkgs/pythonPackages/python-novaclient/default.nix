{ pkgs }:

(import ./requirements.nix { inherit pkgs; }).packages."python-novaclient"
