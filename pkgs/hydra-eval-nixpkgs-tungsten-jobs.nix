{ pkgs }:

let
  inherit (pkgs) writeScriptBin nix hydra bash;
in
  writeScriptBin "hydra-eval-nixpkgs-tungsten-jobs" ''
  #!${bash}/bin/bash

  # NIXPKGS_BOOTSTRAP is only used to fetch fixed output derivations,
  # so we don't care about it's version since the sha of all
  # derivations it builds are checked.
    echo "fetching bootstrap nixpkgs..."
    NIXPKGS_BOOTSTRAP=$(${nix}/bin/nix-instantiate --eval -E 'builtins.fetchTarball { url=https://github.com/NixOS/nixpkgs/archive/acd89daabcb47cb882bc72ffc2d01281ed1fecb8.tar.gz; }' | tr -d '"')

    echo "add to store nixpkgs-tungsten..."
    TUNGSTEN=$(${nix}/bin/nix add-to-store $PWD)

    echo "running hydra-eval-jobs..."
    ${hydra}/bin/hydra-eval-jobs '<tungsten/jobset.nix>' -I tungsten=$TUNGSTEN -I nixpkgs=$NIXPKGS_BOOTSTRAP
  ''
