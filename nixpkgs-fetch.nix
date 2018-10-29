{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.09
    rev = "f12ea6195e4819586ee174d4ef9113b2c1007045";
    sha256 = "07fj3bdq38fcab7acfv0ynxc849g98fd0a671apmjzfbqjg7bm68";};
  }
