{ contrailPkgs, pkgs, fetchgit }:

with pkgs.pythonPackages; buildPythonPackage rec {
  pname = "gremlin-fsck";
  version = "0.1";
  name = "${pname}-${version}";

  src = (import ./sources.nix) fetchgit;

  preBuild = ''
    cd gremlin-fsck
  '';

  patchFlags = "-p2";
  patch = ../../pkgs/patches/TINKERPOP-1887-fsck.patch;

  doCheck = false;
  propagatedBuildInputs = [
    futures
    contrailPkgs.deps.gremlinPython
  ];
}
