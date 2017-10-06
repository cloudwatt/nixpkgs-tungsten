# This file contains expressions to build all OpenContrail components

{ pkgs ? import <nixpkgs> {} }:

with import ./deps.nix {inherit pkgs;};

rec {
  sources = import ./sources.nix { inherit pkgs; };

  contrailBuildInputs = with pkgs; [
      scons gcc5 pkgconfig autoconf automake libtool flex_2_5_35 bison
      # Global build deps
      libkrb5 openssl libxml2 perl tbb curl
      # This overriding should be avoided by patching log4cplus to
      # support older compilers.
      (log4cplus.override{stdenv = pkgs.overrideCC stdenv gcc5;})
      (boost155.override{stdenv = pkgs.overrideCC stdenv gcc5;})

      # api-server
      pythonPackages.lxml pythonPackages.pip
      # To get xxd binary required by sandesh
      vim
      # vrouter-agent
      libipfix
      # analytics
      protobuf2_5 cassandra-cpp-driver
      rdkafka # should be > 0.9
      python zookeeper_mt pythonPackages.sphinx
    ];

  # Hack: we create this derivation to split the downloading from
  # the autotool reconfiguration of thrift made by fetch_packages.
  # Since we want to use http_proxy, we need to have a deterministic
  # output path. However fetch_packages reconfigures thirft and the
  # produced paths are really sensible to autotool versions (that come
  # from nixpkgs).
  thirdPartyCache = pkgs.stdenv.mkDerivation {
    name = "contrail-third-party-cache";
    version = "3.2";

    src = sources.thirdPartySrc;
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    impureEnvVars = pkgs.stdenv.lib.fetchers.proxyImpureEnvVars;
    # We have to fix the output hash to be allowed to set impure env vars.
    # This is really shitty since the hash depends on the autotool version used by thrift.
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "1rvj0dkaw4jbgmr5rkdw02s1krw1307220iwmf2j0p0485p7d3h2";

    buildInputs = with pkgs; [
      pythonPackages.lxml pkgconfig autoconf automake libtool unzip wget
    ];

    buildPhase = "mkdir cache; python fetch_packages.py --cache-dir $PWD/cache";
    installPhase = "mkdir $out; cp -ra cache/* $out/";
  };

  third-party = pkgs.stdenv.mkDerivation {
    name = "contrail-third-party";
    version = "3.2";

    src = sources.thirdPartySrc;
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    buildInputs = with pkgs; [
      pythonPackages.lxml pkgconfig autoconf automake libtool unzip wget
    ];

    buildPhase = "python fetch_packages.py --cache-dir ${thirdPartyCache}";

    installPhase = ''
      # Remove these useless libraries that increase the closure size
      rm -rf boost_1_48_0 icu

      mkdir $out
      cp -ra * $out/
    '';
  };

  controller = pkgs.stdenv.mkDerivation {
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
  };

  sandesh = pkgs.stdenv.mkDerivation rec {
    name = "sandesh";
    version = "3.2";

    src = sources.sandesh;
    patches = [
      (pkgs.fetchurl {
        name = "sandesh.patch";
        url = "https://github.com/Juniper/contrail-sandesh/commit/8b6c1388e9574ab971952734c71d0a5f6ecb8280.patch";
        sha256 = "01gsik13al3zj31ai2r1fg37drv2q0lqnmfvqi736llkma1hc7ik";
      })
      # Some introspects links are missing
      # See https://bugs.launchpad.net/juniperopenstack/+bug/1691949
      (pkgs.fetchurl {
        url = "https://github.com/Juniper/contrail-sandesh/commit/4074d8af7592a564ba1c55c23021cc95f105c6c1.patch";
        sha256 = "1jz4z4y72fqgwpwrmw29pismvackwy187k2yc2xdis8dwrkhpzni";
      })
    ];
    installPhase = "mkdir $out; cp -r * $out";
  };

  contrail-workspace =  pkgs.stdenv.mkDerivation rec {
    name = "contrail-workspace";
    version = "3.2";

    phases = [ "unpackPhase" "patchPhase" "configurePhase" "installPhase" ];

    buildInputs = contrailBuildInputs;

    # We don't override the patchPhase to be nix-shell compliant
    preUnpack = ''mkdir workspace || exit; cd workspace'';
    srcs = with sources; [ build third-party generateds sandesh vrouter neutronPlugin controller ];
    sourceRoot = ''./'';
    postUnpack = ''
      cp ${sources.build.out}/SConstruct .

      mkdir tools
      mv ${sources.build.name} tools/build
      mv ${sources.generateds.name} tools/generateds
      mv ${sandesh.name} tools/sandesh

      [[ ${controller.name} != controller ]] && mv ${controller.name} controller
      [[ ${third-party.name} != third_party ]] && mv ${third-party.name} third_party
      find third_party -name configure -exec chmod 755 {} \;
      [[ ${sources.vrouter.name} != vrouter ]] && mv ${sources.vrouter.name} vrouter

      mkdir openstack
      mv ${sources.neutronPlugin.name} openstack/neutron_plugin
    '';

    prePatch = ''
      # Should be moved in build drv
      sed -i 's|def UseSystemBoost(env):|def UseSystemBoost(env):\n    return True|' -i tools/build/rules.py

      sed -i 's|--proto_path=/usr/|--proto_path=${pkgs.protobuf2_5}/|' tools/build/rules.py
    '';
    installPhase = "mkdir $out; cp -r ./ $out";
  };

  vnc_api = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "vnc_api";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/api-lib";
    propagatedBuildInputs = with pkgs.pythonPackages; [ requests ];
  };

  cfgm_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "cfgm_common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/config/common";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [ psutil geventhttpclient bottle_0_12_1 bitarray ];
  };

  sandesh_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "sandesh-common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/sandesh/common/";
    propagatedBuildInputs = with pkgs.pythonPackages; [  ];
  };

  pysandesh = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "pysandesh";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/tools/sandesh/library/python/";

    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent netaddr ];
  };

  discovery_client = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "discovery-client";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/discovery/client/";
    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent pycassa ];
  };

  control = pkgs.stdenv.mkDerivation rec {
    name = "contrail-control";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      export USER=contrail
      scons -j1 --optimization=production --root=./ contrail-control
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/control-node/contrail-control $out/bin/
      cp ${controller}/src/control-node/contrail-control.conf $out/etc/contrail/
    '';
  };

  collector = pkgs.stdenv.mkDerivation rec {
    name = "contrail-collector";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs ++ [ pkgs.coreutils pkgs.cyrus_sasl.dev pkgs.gperftools pkgs.lz4.dev ];

    # To fix a scons cycle on buildinfo
    patches = ./patches/analytics.patch;
    patchFlags = "-p0";

    buildPhase = ''
      export USER=contrail
      # To export pyconfig.h. This should be patched into the python derivation instead.
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem ${pkgs.python}/include/python2.7/"

      scons -j1 --optimization=production --root=./ contrail-collector
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/analytics/vizd $out/bin/contrail-collector
      cp ${controller}/src/analytics/contrail-collector.conf $out/etc/contrail/
    '';
  };

  vrouterAgent = pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-agent";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      export USER=contrail
      scons -j2 --optimization=production --root=./ contrail-vrouter-agent
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/vnsw/agent/contrail/contrail-vrouter-agent $out/bin/
      cp ${controller}/src/vnsw/agent/contrail-vrouter-agent.conf $out/etc/contrail/
      cp -r build/lib $out/
    '';
  };

  contrailPython = pkgs.stdenv.mkDerivation rec {
    name = "contrail-python";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = with pkgs.pythonPackages; contrailBuildInputs ++
      # Used by python unit tests
      [ bitarray pbr funcsigs mock bottle ];
    propagatedBuildInputs = with pkgs.pythonPackages; [
      psutil geventhttpclient
    ];

    prePatch = ''
      # Don't know if this test is supposed to pass
      substituteInPlace controller/src/config/common/tests/test_analytics_client.py --replace "test_analytics_request_with_data" "nop"

      # It seems these tests require contrail-test repository to be executed
      # See https://github.com/Juniper/contrail-test/wiki/Running-Tests
      for i in svc-monitor/setup.py contrail_issu/setup.py schema-transformer/setup.py vnc_openstack/setup.py api-server/setup.py; do
        sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/$i
      done

      # Tests are disabled because they requires to compile vizd (collector)
      sed -i '/OpEnv.AlwaysBuild(test_cmd)/d' controller/src/opserver/SConscript
    '';
    buildPhase = ''
      export USER=contrail
      export PYTHONPATH=$PYTHONPATH:controller/src/config/common/:build/production/config/api-server/vnc_cfg_api_server/gen/
      scons -j1 --optimization=production --root=./ controller/src/config

      scons -j1 --optimization=production --root=./ contrail-analytics-api
      scons -j1 --optimization=production --root=./ contrail-discovery
    '';
    installPhase = "mkdir $out; cp -r build/* $out";
  };

  api =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-api-server";
    version = "3.2";
    src = "${contrailPython}/production/config/api-server/";
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore discovery_client netifaces
    ];
  };

  # Contains more than just the contrail-analytics-api!
  analyticsApi =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-analytics-api";
    version = "3.2";
    src = "${contrailPython}/production/opserver/";
    prePatch = ''
      sed -i 's/sseclient/sseclient_py/' requirements.txt
    '';
    propagatedBuildInputs = with pkgs.pythonPackages; [
     lxml geventhttpclient psutil redis bottle_0_12_1 xmltodict sseclient pycassa requests prettytable
     # Not in requirements.txt...
     pysandesh cassandra-driver sandesh_common discovery_client cfgm_common stevedore kafka vnc_api
    ];
  };

  schemaTransformer =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-schema-transformer";
    version = "3.2";
    src = "${contrailPython}/production/config/schema-transformer//";
    # To be cleaned
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore discovery_client netifaces jsonpickle
    ];
  };

  discovery =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-discovery";
    version = "3.2";
    src = "${contrailPython}/production/discovery";
    propagatedBuildInputs = with pkgs.pythonPackages; [
      gevent pycassa
      # Not in requirements.txt...
      cfgm_common vnc_api pysandesh sandesh_common xmltodict discovery_client
    ];
  };

  vrouterUtils = pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-utils";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = pkgs.lib.remove pkgs.gcc contrailBuildInputs ++ [ pkgs.libpcap pkgs.libnl ];
    buildPhase = ''
      export USER=contrail
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem ${pkgs.libxml2.dev}/include/libxml2/"
      scons --optimization=production --root=./ vrouter/utils
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp build/production/vrouter/utils/usr/bin/* $out/bin/
    '';
  };


  vrouter = kernelHeaders: pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-${kernelHeaders.name}";
    version = "3.2";
    src = contrail-workspace;
    # We switch to gcc 4.9 because gcc 5 is not supported before kernel 3.18
    buildInputs = pkgs.lib.remove pkgs.gcc contrailBuildInputs ++ [ pkgs.gcc49 ];
    buildPhase = ''
      export USER=contrail
      export hardeningDisable=pic
      # To compile the module, we need the kernel sources and the kernel config
      kernelSrc=$(echo ${kernelHeaders}/lib/modules/*/build/)
      scons --optimization=production --root=./ --kernel-dir=$kernelSrc vrouter/vrouter.ko
    '';
    installPhase = ''
      kernelVersion=$(ls ${kernelHeaders}/lib/modules/)
      mkdir -p $out/lib/modules/$kernelVersion/extra/net/vrouter/
      cp vrouter/vrouter.ko $out/lib/modules/$kernelVersion/extra/net/vrouter/
    '';
  };

  configUtils = pkgs.stdenv.mkDerivation rec {
   name = "contrail-config-utils";
   version = "3.2";
   src = contrail-workspace;
   phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
   buildInputs = [
    (pkgs.python27.withPackages (pythonPackages: with pythonPackages; [
       netaddr vnc_api cfgm_common ]))
   ];
   installPhase = ''
     mkdir -p $out/bin
     cp controller/src/config/utils/*.{py,sh} $out/bin
   '';
  };

  vrouterPortControl = pkgs.stdenv.mkDerivation rec {
   name = "contrail-vrouter-port-control";
   version = "3.2";
   src = contrail-workspace;
   phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
   buildInputs = [
    (pkgs.python27.withPackages (pythonPackages: with pythonPackages; [
       netaddr requests ]))
   ];
   installPhase = ''
     mkdir -p $out/bin
     cp controller/src/vnsw/agent/port_ipc/vrouter-port-control $out/bin
   '';
  };

  vrouterApi = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "contrail-vrouter-api";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrail-workspace}/controller/src/vnsw/contrail-vrouter-api/";
  };

  vrouterNetns =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-vrouter-netns";
    version = "3.2";
    src = "${contrail-workspace}/controller/src/vnsw/opencontrail-vrouter-netns/";
    patchPhase = ''
      substituteInPlace requirements.txt --replace "docker-py" "docker"
      substituteInPlace opencontrail_vrouter_netns/lxc_manager.py --replace "dhclient" "${pkgs.dhcp}/bin/dhclient"
    '';
    # Try to access /var/log/contrail/contrail-lbaas-haproxy-stdout.log
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      docker netaddr contrailVrouterApi eventlet vnc_api cfgm_common
    ];
  };

  queryEngine = pkgs.stdenv.mkDerivation rec {
    name = "contrail-query-engine";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      export USER=contrail
      scons -j1 --optimization=production --root=./ contrail-query-engine
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/query_engine/qed $out/bin/
      cp ${controller}/src/query_engine/contrail-query-engine.conf $out/etc/contrail/
    '';
  };
}
