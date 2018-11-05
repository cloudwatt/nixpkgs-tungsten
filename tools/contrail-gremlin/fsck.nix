{ pkgs, fetchFromGitHub }:

let

  gremlinPython = with pkgs.python27Packages; buildPythonPackage rec {
    pname = "gremlinpython";
    version = "3.3.2";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1fml9r52x56cg4ghcyrf5zs74c8lcr2da8nbicdmf88j0fbpgzds";
    };

    doCheck = false;
    propagatedBuildInputs = [ six aenum futures tornado_4 pytestrunner ];
  };

in

  with pkgs.pythonPackages; buildPythonPackage rec {
    pname = "gremlin-fsck";
    version = "0.1";
    name = "${pname}-${version}";

    src = (import ./sources.nix) fetchFromGitHub;

    preBuild = ''
      cd gremlin-fsck
    '';

    doCheck = false;
    propagatedBuildInputs = [
      futures
      gremlinPython
    ];
  }
