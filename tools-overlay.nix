self: super:
let inherit (super) callPackage callPackages;
in {
  contrailIntrospectCli = callPackage ./tools/contrail-introspect-cli { };
  contrailApiCliWithExtra = callPackage ./tools/contrail-api-cli { };
  contrailGremlin = callPackage ./tools/contrail-gremlin { };
  gremlinChecks = callPackage ./tools/contrail-gremlin/checks.nix { };
  gremlinConsole = callPackage ./tools/gremlin-console { };
  gremlinServer = callPackage ./tools/gremlin-server { };
  gremlinFsck = callPackage ./tools/contrail-gremlin/fsck.nix { };
}
