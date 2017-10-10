{pkgs, sources, contrailBuildInputs }:

let
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

in pkgs.stdenv.mkDerivation rec {
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
}

