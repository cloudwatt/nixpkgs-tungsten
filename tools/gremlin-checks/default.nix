{ contrailPkgs, pkgs, fetchurl, stdenv }:

let
  gremlinChecksScript = fetchurl {
    url = "https://raw.githubusercontent.com/eonpatapon/contrail-gremlin/master/gremlin-checks/checks.groovy";
    sha256 = "1p74kiakbgbsma6a45k736j5319k499zk23s9qg43mqdpx3hz8l3";
  };
in
  pkgs.writeShellScriptBin "gremlin-checks" ''
    ${contrailPkgs.tools.gremlinConsole}/bin/gremlin-console -i ${gremlinChecksScript} $1
''
