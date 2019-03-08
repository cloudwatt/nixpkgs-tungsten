{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  tools = import ./tools-overlay.nix;
  contrail = import ./contrail-overlay.nix;
  pkgs = import nixpkgs { overlays = [ tools contrail ]; };
  dockerImages = pkgs.callPackages ./pkgs/docker-images/default.nix { };

in pkgs // { inherit dockerImages; }
