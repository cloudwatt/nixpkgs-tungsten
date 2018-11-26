{ stdenv
, pkgs
, deps
, contrailThirdParty
}:

with builtins;

stdenv.mkDerivation rec {
  name = "simple-ampq-client-${version}";
  version = "2.4.0";
  buildInputs = with pkgs; [
    cmake rabbitmq-c deps.boost
  ];
  src = contrailThirdParty;
  sourceRoot = "./contrail-third-party/SimpleAmqpClient";
  cmakeFlags = [
    "-DENABLE_SSL_SUPPORT=ON"
    "-DBUILD_SHARED_LIBS=OFF"
  ];
}
