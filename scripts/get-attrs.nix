{ pkgs ? import <nixpkgs> {} }: 

let

  inherit (pkgs) lib;
  versions = import ../contrail-versions.nix;
  jobset = import ../jobset.nix {};

  contrailVersions = map (x: "contrail${lib.concatStrings (lib.splitString "." x)}") versions;
  prefixWith = prefix: xs: map (x: "${prefix}.${x}") xs;
  general = lib.subtractLists contrailVersions  (lib.attrNames jobset);
  allContrailAttrs = lib.concatMap (x: prefixWith x (lib.attrNames jobset."${x}")) contrailVersions;
  allContrailTests = lib.concatMap (x: prefixWith "${x}.test" (lib.attrNames jobset."${x}".test)) contrailVersions;

in

  {
    all = general ++ allContrailAttrs;
    tests = allContrailTests;
  }
