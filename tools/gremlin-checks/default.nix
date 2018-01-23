{ contrailPkgs, pkgs, fetchurl, stdenv }:

let
  gremlinChecksScript = fetchurl {
    url = "https://raw.githubusercontent.com/eonpatapon/contrail-gremlin/master/gremlin-checks/checks.groovy";
    sha256 = "1p74kiakbgbsma6a45k736j5319k499zk23s9qg43mqdpx3hz8l3";
  };
in
{
  gremlinChecks = pkgs.writeScriptBin "gremlin-checks" ''
#!${stdenv.shell}
${contrailPkgs.tools.contrailGremlin}/bin/gremlin-dump /tmp/dump.gson && ${contrailPkgs.tools.gremlinConsole}/bin/gremlin-console -i ${gremlinChecksScript} /tmp/dump.gson
'';
}
