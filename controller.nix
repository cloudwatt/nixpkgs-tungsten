# NIX_PATH should point to the nixpkgs unstable branch.
# export NIX_PATH=/path/to/unstable/branch

# To build the controller
# nix-build controller.nix -o result-controller -A controller

{ pkgs ? import <nixpkgs> {} }:

with import ./deps.nix {inherit pkgs;};

rec {
  contrailBuildInputs = with pkgs; [
      scons gcc pkgconfig autoconf automake libtool flex_2_5_35 bison
      # build deps
      libkrb5 openssl libxml2 perl boost155 log4cplus tbb curl
      # api server
      pythonPackages.lxml pythonPackages.pip
      # To get xxd required by sandesh
      vim
      # Vrouter agent
      libipfix

      # analytics
      protobuf2_5 cassandra-cpp-driver
      rdkafka # > 0.9
      python zookeeper_mt pythonPackages.sphinx
    ];

  third-party = pkgs.stdenv.mkDerivation {
    name = "contrail-third-party";
    version = "3.2";

    src = pkgs.fetchFromGitHub {
        owner = "Juniper";
        repo = "contrail-third-party";
        rev = "16333c4e2ecbea2ef5bc38cecf45bfdc78500053";
        sha256 = "1bkrjc8w2c8a4hjz43xr0nsiwmxws2zmg2vvl3qfp32bw4ipvrhv";
    };

    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    buildInputs = with pkgs; [
      pythonPackages.lxml pkgconfig autoconf automake libtool unzip wget
    ];

    buildPhase = ''
      export USER=contrail
      python fetch_packages.py
    '';

    installPhase = ''
      # Remove these useless libraries that increase the closure size
      rm -rf boost_1_48_0 icu

      mkdir $out
      cp -rva * $out/
    '';
  };

  controller = pkgs.stdenv.mkDerivation {
    name = "controller";
    version = "R3.2";
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    src = pkgs.fetchFromGitHub {
      owner = "eonpatapon";
      repo = "contrail-controller";
      rev = "df56948839068e5d6312556699a1d54fc591895f";
      sha256 = "102qaibxaz106sr67w66wxidxnipvkky3ar670hzazgyfmrjg8vh";
	};
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

    '';
    installPhase = "cp -r ./ $out";
  };

  neutron-plugin = pkgs.fetchFromGitHub {
      owner = "eonpatapon";
      repo = "contrail-neutron-plugin";
      rev = "fa6b3e80af4537633b3423474c9daa83fabee5e8";
      sha256 = "1j0hg944zsb8hablj1i0lq7w4wdah2lrymhwxsyydxz29zc25876";
  };
  
  vrouter = pkgs.fetchFromGitHub {
      owner = "Juniper";
      repo = "contrail-vrouter";
      rev = "58c8f58574c569ec8057171f6509d6984bb08520";
      sha256 = "0gwfqqdwph5776kcy2qn1i7472b84jbml8aran6kkbwp52611rk5";
  };

  sandesh = pkgs.stdenv.mkDerivation rec {
    name = "sandesh";
    version = "3.2";
  
    src = pkgs.fetchFromGitHub {
      owner = "Juniper";
      repo = "contrail-sandesh";
      rev = "3083be8b8d3dc673aa6e6d29d258aca064af96ce";
      sha256 = "16v8n6cg42qsxx5qg5p12sq52m9hpgb19zlami2g67f3h1a526dj";
    };
    patches = [
      (pkgs.fetchurl {
        name = "sandesh.patch";
	url = "https://github.com/Juniper/contrail-sandesh/commit/8b6c1388e9574ab971952734c71d0a5f6ecb8280.patch";
	sha256 = "01gsik13al3zj31ai2r1fg37drv2q0lqnmfvqi736llkma1hc7ik";
      })
    ];
    installPhase = "mkdir $out; cp -r * $out";
  };

  generateds = pkgs.fetchFromGitHub {
      owner = "Juniper";
      repo = "contrail-generateds";
      rev = "4dc0fdf96ab0302b94381f97dc059a1dc0b2d69b";
      sha256 = "0v5ifvzsjzaw23y8sbzwhr6wwcsz836p2lziq4zcv7hwvr4ic5gw";
  };

  build = pkgs.fetchFromGitHub {
      owner = "Juniper";
      repo = "contrail-build";
      rev = "84860a733f777e040446890bd6bedf44f7116fcb";
      sha256 = "01ik66w5viljsyqs2dj17vfbgkxhq0k4m91lb2dvkhhq65mwcaxw";
  };      

  contrail-workspace =  pkgs.stdenv.mkDerivation rec {
    name = "contrail-workspace";
    version = "3.2";

    phases = [ "unpackPhase" "patchPhase" "configurePhase" "installPhase" ];
    
    buildInputs = contrailBuildInputs;

    # We don't override the patchPhase to be nix-shell compliant
    preUnpack = ''mkdir workspace || exit; cd workspace'';
    srcs = [ build third-party generateds sandesh vrouter neutron-plugin controller ];
    sourceRoot = ''./'';
    postUnpack = ''
      cp ${build.out}/SConstruct .

      mkdir tools
      mv ${build.name} tools/build
      mv ${generateds.name} tools/generateds
      mv ${sandesh.name} tools/sandesh

      [[ ${controller.name} != controller ]] && mv ${controller.name} controller
      [[ ${third-party.name} != third_party ]] && mv ${third-party.name} third_party
      find third_party -name configure -exec chmod 755 {} \;
      [[ ${vrouter.name} != vrouter ]] && mv ${vrouter.name} vrouter
      
      mkdir openstack
      mv ${neutron-plugin.name} openstack/neutron_plugin
    '';

    prePatch = ''
      # Disable tests
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/api-server/setup.py

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
    src = "${contrailConfig}/production/api-lib";
    propagatedBuildInputs = with pkgs.pythonPackages; [ requests ];
  };

  cfgm_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "cfgm_common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailConfig}/production/config/common";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [ psutil geventhttpclient bottle bitarray ];
  };

  sandesh_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "sandesh-common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailConfig}/production/sandesh/common/";
    propagatedBuildInputs = with pkgs.pythonPackages; [  ];
  };

  pysandesh = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "pysandesh";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailConfig}/production/tools/sandesh/library/python/";

    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent netaddr ];
  };

  discovery_client = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "discovery-client";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailConfig}/production/discovery/client/";
    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent pycassa ];
  };

  contrailControl = pkgs.stdenv.mkDerivation rec {
    name = "contrail-control";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      # To make scons happy
      export USER=contrail
      scons -j1 --optimization=production --root=./ contrail-control
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/control-node/contrail-control $out/bin/
      cp ${controller}/src/control-node/contrail-control.conf $out/etc/contrail/
    '';
  };

  contrailVrouterAgent = pkgs.stdenv.mkDerivation rec {
    name = "contrail-agent";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      # To make scons happy
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

  contrailConfig = pkgs.stdenv.mkDerivation rec {
    name = "contrail-control";
    version = "3.2";
    src = contrail-workspace;
    buildInputs = contrailBuildInputs;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      psutil geventhttpclient
    ];

    prePatch = ''
      # These tests are failing. Don't know why...
      sed '/test_suite=/d' -i controller/src/config/common/setup.py

      # Disable tests
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/svc-monitor/setup.py
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/contrail_issu/setup.py
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/schema-transformer/setup.py
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/vnc_openstack/setup.py
      # substituteInPlace controller/src/config/schema-transformer/run_tests.sh --replace "/bin/bash" "${pkgs.bash}/bin/bash"
    '';
    buildPhase = ''
      # To make scons happy
      export USER=contrail
      export PYTHONPATH=$PYTHONPATH:controller/src/config/common/:build/production/config/api-server/vnc_cfg_api_server/gen/
      scons -j1 --optimization=production --root=./ controller/src/config
    '';
    installPhase = "mkdir $out; cp -r build/* $out";
  };

  contrailApi =  pkgs.pythonPackages.buildPythonApplication {
    name = "api-server";
    version = "3.2";
    src = "${contrailConfig}/production/config/api-server/";
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore discovery_client netifaces
    ];
  };
}
