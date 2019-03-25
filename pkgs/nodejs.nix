{ pkgs, fetchurl }:

pkgs.nodejs-6_x.overrideAttrs (old: rec {
  name = "nodejs-4.8.7";
  version = "4.8.7";
  sha256 = "1y21wq092d3gmccm2zldbflbbbx7a71wi9l0bpkxvzmgws69liq3";
  src = fetchurl {
    url = "http://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
    inherit sha256;
  };
})
