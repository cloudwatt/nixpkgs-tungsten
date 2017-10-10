{ bootstrap_pkgs ? <nixpkgs>
, fetched ? import ./nixpkgs-fetch.nix { nixpkgs = bootstrap_pkgs; }
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  contrailPkgs = import ./default.nix { inherit nixpkgs; };
in
  contrailPkgs
