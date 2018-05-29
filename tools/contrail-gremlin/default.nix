{ pkgs, buildGo110Package, fetchFromGitHub }:

buildGo110Package rec {
  name = "contrail-gremlin-${version}";
  version = "2018-01-23";

  src = (import ./sources.nix) fetchFromGitHub;

  goPackagePath = "github.com/eonpatapon/contrail-gremlin";
  goDeps = ./deps.nix;
}
