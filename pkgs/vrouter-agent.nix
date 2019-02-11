{ pkgs
, lib
, stdenv
, deps
, contrailVersion
, contrailWorkspace
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-vrouter-agent-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  NIX_CFLAGS_COMPILE = [
    "-Wno-unused-but-set-variable"
    "-isystem ${deps.thrift}/include/thrift"
  ];
  buildInputs = with pkgs; [
    scons libipfix libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    pythonPackages.lxml
    deps.boost deps.thrift deps.log4cplus deps.bind deps.tbb
    makeWrapper
  ] ++ (optional lib.versionAtLeast41 [
    gperftools deps.simpleAmqpClient deps.cassandraCppDriver
  ]);
  separateDebugInfo = true;
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
