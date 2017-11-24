{pkgs, contrailBuildInputs, deps, workspace, isContrail32 }:

pkgs.stdenv.mkDerivation {
  name = "contrail-collector";
  version = "3.2";
  src = workspace;
  USER="contrail";

  # Only required on master
  dontUseCmakeConfigure = true;
  buildInputs = contrailBuildInputs ++
                [ pkgs.coreutils pkgs.cyrus_sasl.dev pkgs.gperftools pkgs.lz4.dev deps.libgrok pkgs.pcre.dev pkgs.tokyocabinet pkgs.libevent.dev ] ++
                (pkgs.lib.optional (!isContrail32) [ pkgs.cmake pkgs."rabbitmq-c" ]);

  # To fix a scons cycle on buildinfo
  patches = pkgs.lib.optional isContrail32 [ ./patches/analytics.patch ];
  patchFlags = "-p0";

  buildPhase = ''
    # To export pyconfig.h. This should be patched into the python derivation instead.
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem ${pkgs.python}/include/python2.7/"

    scons -j1 --optimization=production contrail-collector
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/analytics/vizd $out/bin/contrail-collector
    cp ${workspace}/controller/src/analytics/contrail-collector.conf $out/etc/contrail/
  '';
}
