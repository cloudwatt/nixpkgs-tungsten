{ contrailPkgs, pkgs, fetchgit, stdenv }:

let
  src = (import ./sources.nix) fetchgit;
in
  pkgs.writeShellScriptBin "gremlin-checks" ''
    if [ "" == "$1" ]; then
      echo "Usage: $0 <path/to/dump>"
      exit 1
    fi
    if [ ! -f $1 ]; then
      echo File not found
      exit 1
    fi
    ${contrailPkgs.tools.gremlinConsole}/bin/gremlin-console -i ${src}/gremlin-checks/checks.groovy $1
  ''
