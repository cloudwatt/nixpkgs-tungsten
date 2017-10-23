{pkgs, sources}:

pkgs.stdenv.mkDerivation {
  name = "controller";
  version = "R3.2";
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];
  src = sources.controller;
  patchPhase = ''
    sed -i "s|config_opts = |config_opts = ' --with-openssl=${pkgs.openssl.dev} ' + |" lib/bind/SConscript

    # Third party lib to be used are defined by discovering the
    #	distro. To avoid this, we fix them.
    substituteInPlace lib/SConscript --replace \
      'for dir in subdirs:' \
      'for dir in ["bind", "gunit", "hiredis", "http_parser", "pugixml", "rapidjson", "thrift", "openvswitch", "tbb" ]:'

    substituteInPlace src/vnsw/agent/pkt/SConscript --replace \
      'AgentEnv.Clone()' \
      'AgentEnv.Clone(); cflags = env["CCFLAGS"]; cflags.append("-Wno-error=maybe-uninitialized"); env.Replace(CCFLAGS = cflags)'

    # Should be only applied on file controller/src/vnsw/agent/vrouter/ksync/ksync_flow_memory.cc
    # This is because we are using glibc2.25. No warning before glibc2.24
    substituteInPlace src/vnsw/agent/vrouter/ksync/SConscript --replace \
      'env = AgentEnv.Clone()' \
    'env = AgentEnv.Clone(); env.Replace(CFFLAGS = env["CCFLAGS"].remove("-Werror"))'

    substituteInPlace src/dns/cmn/SConscript \
      --replace "buildinfo_dep_libs +  cmn_sources +" "buildinfo_dep_libs +"

    substituteInPlace src/control-node/SConscript \
      --replace "['main.cc', 'options.cc', 'sandesh/control_node_sandesh.cc']" "[]"

    # To break scons cycle on buildinfo
    substituteInPlace src/query_engine/SConscript \
      --replace "source = buildinfo_dep_libs + qed_sources + SandeshGenSrcs +" "source = buildinfo_dep_libs + SandeshGenSrcs +"
  '';
  installPhase = "cp -r ./ $out";
}

