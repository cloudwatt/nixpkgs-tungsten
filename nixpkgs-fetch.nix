{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.03-cloudwatt
    rev = "590320e107e1a047061d0a7d801830f61be38082";
    sha256 = "0pr404mrjcwhxckkhp4qscxh73nsb3yxwy41hy6cdsvvj53zc3ji";};
  }
