{ stdenv
, deps
, contrailVersion
, contrailBuildInputs
, contrailWorkspace
}:

stdenv.mkDerivation rec {
  name = "contrail-query-engine-${version}";
  version = contrailVersion;
  buildInputs = contrailBuildInputs;
  src = contrailWorkspace;
  USER = "contrail";
  NIX_CFLAGS_COMPILE = "-isystem ${deps.thrift}/include/thrift";
  buildPhase = ''
    scons -j1 --optimization=production contrail-query-engine
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/query_engine/qed $out/bin/
    cp ${contrailWorkspace}/controller/src/query_engine/contrail-query-engine.conf $out/etc/contrail/
  '';
}
