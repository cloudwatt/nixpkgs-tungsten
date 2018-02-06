{ pkgs, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "contrail-gremlin-${version}";
  version = "2018-01-23";

  src = (import ./sources.nix) fetchgit;

  goPackagePath = "github.com/eonpatapon/contrail-gremlin";
  goDeps = ./deps.nix;

  postInstall = ''
    mkdir -p $bin/conf
    cp -v go/src/github.com/eonpatapon/contrail-gremlin/conf/* $bin/conf
    sed -i "s!conf/\(.*\).properties!$bin/conf/\1.properties!" $bin/conf/*.yaml
  '';
}
