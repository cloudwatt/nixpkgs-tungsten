{ pkgs
, stdenv
, contrailThirdParty
}:

with builtins;

stdenv.mkDerivation rec {
  name = "bind-${version}";
  version = "9.10.4-P2";
  buildInputs = with pkgs; [ openssl perl ];
  src = contrailThirdParty;
  sourceRoot = "./contrail-third-party/${name}";
  configureFlags = [
    "--enable-threads"
    "--enable-fixed-rrset"
    "--with-openssl=${pkgs.openssl.dev}"
  ];
}
