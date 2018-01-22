{ contrailPkgs, pkgs, fetchurl, stdenv }:

rec {

  gremlinChecksScript = fetchurl {
    url = "https://raw.githubusercontent.com/eonpatapon/contrail-gremlin/master/gremlin-checks/checks.groovy";
    sha256 = "1p74kiakbgbsma6a45k736j5319k499zk23s9qg43mqdpx3hz8l3";
  };

  gremlinChecks= pkgs.writeScriptBin "gremlin-checks" ''
#!${pkgs.bash}/bin/bash
${contrailPkgs.tools.gremlinDump}/bin/gremlin-dump /tmp/dump.gson && ${contrailPkgs.tools.gremlinConsole}/bin/gremlin -i ${gremlinChecksScript} /tmp/dump.gson
  '';

}
