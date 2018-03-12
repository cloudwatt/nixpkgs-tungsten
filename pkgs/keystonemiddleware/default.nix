{ pkgs }:

let generated =  import ./requirements.nix { inherit pkgs; };
in generated.packages.keystonemiddleware
