{ stdenv, contrailBuildInputs, workspace, contrailVersion }:

stdenv.mkDerivation rec {
    name = "contrail-query-engine-${version}";
    version = contrailVersion;
    src = workspace;
    USER="contrail";
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      scons -j1 --optimization=production contrail-query-engine
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/query_engine/qed $out/bin/
      cp ${workspace}/controller/src/query_engine/contrail-query-engine.conf $out/etc/contrail/
    '';
}
