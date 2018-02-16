{ contrailPkgs, pkgs, fetchgit }:

with pkgs.pythonPackages; buildPythonPackage rec {
  pname = "gremlin-fsck";
  version = "0.1";
  name = "${pname}-${version}";

  src = (import ./sources.nix) fetchgit;

  preBuild = ''
    cd gremlin-fsck
  '';

  doCheck = false;
  propagatedBuildInputs = [
    futures
    contrailPkgs.deps.gremlinPython
  ];
}
