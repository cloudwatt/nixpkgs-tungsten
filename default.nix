{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  tools = import ./tools-overlay.nix;
  contrail = import ./contrail-overlay.nix;

in import nixpkgs { overlays = [ tools contrail ]; }
