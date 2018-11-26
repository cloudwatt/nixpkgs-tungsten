{ bootstrap_pkgs ? <nixpkgs>
, fetched ? import ./nixpkgs-fetch.nix { nixpkgs = bootstrap_pkgs; }
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import ./default.nix { inherit nixpkgs; };
in with pkgs; {
  inherit contrailIntrospectCli;
  inherit contrailApiCliWithExtra;
  inherit contrailGremlin;
  inherit gremlinChecks;
  inherit gremlinConsole;
  inherit gremlinServer;
  inherit gremlinFsck;
  contrail32 = contrail32.lib.sanitizeOutputs contrail32;
  contrail41 = contrail41.lib.sanitizeOutputs contrail41;
}
