{pkgs, stdenv, contrailBuildInputs, workspace, isContrailMaster, contrailVersion }:

stdenv.mkDerivation rec {
  name = "contrail-vrouter-agent-${version}";
  version = contrailVersion;
  src = workspace;
  USER="contrail";
  # Only required on master
  dontUseCmakeConfigure = true;
  NIX_CFLAGS_COMPILE = "-Wno-unused-but-set-variable"; 
  buildInputs = contrailBuildInputs ++
    (pkgs.lib.optional isContrailMaster [ pkgs.cmake pkgs."rabbitmq-c" pkgs.gperftools ]);
  buildPhase = ''
    scons -j2 --optimization=production contrail-vrouter-agent
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/vnsw/agent/contrail/contrail-vrouter-agent $out/bin/
    cp ${workspace}/controller/src/vnsw/agent/contrail-vrouter-agent.conf $out/etc/contrail/
    cp -r build/lib $out/
  '';
}

