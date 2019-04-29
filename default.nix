{ nixpkgs ? import ./nixpkgs-fetch.nix {} }:

let
  tools = import ./tools-overlay.nix;
  contrail = import ./contrail-overlay.nix;

in import nixpkgs { overlays = [ tools contrail ]; }
