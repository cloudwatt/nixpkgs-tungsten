{ pkgs
, stdenv
, deps
, contrailVersion
, contrailWorkspace
, isContrail32
, isContrail41
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-collector-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    deps.libgrok deps.thrift deps.boost deps.log4cplus
    deps.cassandraCppDriver deps.tbb
    coreutils cyrus_sasl.dev gperftools lz4.dev pcre.dev
    tokyocabinet libevent.dev libipfix protobuf2_5
    rdkafka zookeeper_mt
  ] ++ (optionals isContrail41 [
    deps.simpleAmqpClient pythonPackages.lxml rabbitmq-c
  ]);
  USER = "contrail";
  # To export pyconfig.h. This should be patched into the python derivation instead.
  NIX_CFLAGS_COMPILE = "-isystem ${deps.thrift}/include/thrift -isystem ${pkgs.python}/include/python2.7";
  # To fix a scons cycle on buildinfo
  patches = optional isContrail32 [ ./patches/analytics.patch ];
  patchFlags = "-p0";
  separateDebugInfo = true;
  buildPhase = ''
    scons -j2 --optimization=production contrail-collector
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/analytics/vizd $out/bin/contrail-collector
    cp ${contrailWorkspace}/controller/src/analytics/contrail-collector.conf $out/etc/contrail/
    cp -r build/lib $out/
  '';
}
