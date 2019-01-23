{ stdenv
, pkgs
, contrailThirdParty
, boost
}:

with builtins;

stdenv.mkDerivation rec {
  name = "thrift-${version}";
  version = "0.8.0";
  buildInputs = with pkgs; [ boost openssl ];
  src = contrailThirdParty;
  sourceRoot = "./contrail-third-party/${name}";
  configureFlags = [
    "--disable-dependency-tracking"
    "--without-csharp"
    "--without-java"
    "--without-erlang"
    "--without-python"
    "--without-perl"
    "--without-php"
    "--without-ruby"
    "--without-haskell"
    "--without-go"
    "--without-tests"
  ];
}
