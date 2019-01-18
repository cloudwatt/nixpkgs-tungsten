{ pkgs
, stdenv
, deps
, contrailVersion
, contrailBuildInputs
, contrailWorkspace
, isContrailMaster }:

stdenv.mkDerivation rec {
  name = "contrail-control-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  # Only required on master
  dontUseCmakeConfigure = true;

  NIX_CFLAGS_COMPILE = "-isystem ${deps.thrift}/include/thrift";

  buildInputs = with pkgs;
    contrailBuildInputs ++
    (pkgs.lib.optional isContrailMaster [ cmake rabbitmq-c gperftools ]);

  buildPhase = ''
    scons -j1 --optimization=production contrail-control
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/control-node/contrail-control $out/bin/
    cp ${contrailWorkspace}/controller/src/control-node/contrail-control.conf $out/etc/contrail/
  '';
}

