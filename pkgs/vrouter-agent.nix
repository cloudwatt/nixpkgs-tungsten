{ pkgs
, stdenv
, contrailVersion
, contrailWorkspace
, isContrailMaster
, boost
, thrift
, log4cplus
, bind
, tbb
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-vrouter-agent-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  # Only required on master
  dontUseCmakeConfigure = true;
  NIX_CFLAGS_COMPILE = "-Wno-unused-but-set-variable -isystem ${thrift}/include/thrift";
  buildInputs = with pkgs; [
    scons libipfix libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    pythonPackages.lxml
    boost thrift log4cplus bind tbb
    makeWrapper
  ] ++ (optional isContrailMaster [
    pkgs.cmake pkgs.rabbitmq-c pkgs.gperftools
  ]);
  buildPhase = ''
    scons -j4 --optimization=production contrail-vrouter-agent
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/vnsw/agent/contrail/contrail-vrouter-agent $out/bin/
    cp ${contrailWorkspace}/controller/src/vnsw/agent/contrail-vrouter-agent.conf $out/etc/contrail/
    cp -r build/lib $out/
  '';
  postFixup = ''
    wrapProgram "$out/bin/contrail-vrouter-agent" --prefix PATH ":" "${pkgs.procps}/bin"
  '';
}
