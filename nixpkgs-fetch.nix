{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.03
    rev = "2ee48415afc58cb9043a2463e0bde1a91d46c09a";
    sha256 = "1fca1mfpzb2r4ijxllrcyl8qzbws9wxlvqr3fsh4agrpkf68rci5";};
  }
