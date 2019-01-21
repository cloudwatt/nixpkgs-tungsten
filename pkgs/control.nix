{ pkgs
, stdenv
, deps
, contrailVersion
, contrailWorkspace
, isContrailMaster
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-control-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    deps.thrift deps.boost deps.log4cplus deps.tbb
    pythonPackages.lxml
  ] ++ (optional isContrailMaster [
    cmake rabbitmq-c gperftools
  ]);
  USER = "contrail";
  # Only required on master
  dontUseCmakeConfigure = true;
  NIX_CFLAGS_COMPILE = "-isystem ${deps.thrift}/include/thrift";
  buildPhase = ''
    scons -j2 --optimization=production contrail-control
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/control-node/contrail-control $out/bin/
    cp ${contrailWorkspace}/controller/src/control-node/contrail-control.conf $out/etc/contrail/
  '';
}

