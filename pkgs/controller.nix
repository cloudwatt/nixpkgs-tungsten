{pkgs, sources, isContrailMaster, isContrail32}:

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
      'for dir in ["bind", "gunit", "hiredis", "http_parser", "pugixml", "rapidjson", "thrift", "openvswitch", "tbb" ${pkgs.lib.optionalString isContrailMaster '', "SimpleAmqpClient" ''}]:'

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

    # To break scons cycle on buildinfo
    substituteInPlace src/query_engine/SConscript \
      --replace "source = buildinfo_dep_libs + qed_sources + SandeshGenSrcs +" "source = buildinfo_dep_libs + SandeshGenSrcs +"
    '' +
    pkgs.lib.optionalString isContrail32 ''
      # This has to be backported to 3.2
      # https://bugs.launchpad.net/juniperopenstack/+bug/1638636
      # and commit
      # https://github.com/Juniper/contrail-controller/commit/7ef887e340485414b9c2c1be8b44cda74dd0fcf3
      # substituteInPlace src/analytics/syslog_collector.cc \
      #   --replace "<boost/spirit/home/phoenix/object/construct.hpp>" "<boost/phoenix/object/construct.hpp>"
      # sed -i 1i'#include <cstring>'  src/zookeeper/zookeeper_client.cc

      substituteInPlace src/control-node/SConscript \
        --replace "['main.cc', 'options.cc', 'sandesh/control_node_sandesh.cc']" "[]"
    '' +
    pkgs.lib.optionalString isContrailMaster ''
      substituteInPlace src/control-node/SConscript \
        --replace "['main.cc', 'options.cc']" "[]"

      substituteInPlace src/analytics/SConscript \
        --replace "source = AnalyticsSandeshGenSrcs + vizd_sources + ProtobufGenSrcs +" \
                  "source = AnalyticsSandeshGenSrcs + ProtobufGenSrcs +"
      substituteInPlace src/analytics/SConscript \
        --replace "'main.cc']" "]"
    '';
  installPhase = "cp -r ./ $out";
}

