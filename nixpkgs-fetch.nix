{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.09
    rev = "7e88992a8c7b2de0bcb89182d8686b27bd93e46a";
    sha256 = "1f6lf4addczi81hchqbzjlhrsmkrj575dmdjdhyl0jkm7ypy2lgk";};
  }
