{ pkgs, lib, fetchFromGitHub }:

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

  prometheusClient = with pkgs.python27Packages; buildPythonPackage rec {
    pname = "prometheus_client";
    version = "0.6.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1474rr7p4ihzpix1z0wwhpc99jf06fk95ayrph4g4rhgfmcbjf0v";
    };

    doCheck = false;

    meta = with lib; {
      description = "Prometheus instrumentation library for Python applications";
      homepage = https://github.com/prometheus/client_python;
      license = licenses.asl20;
    };
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
      prometheusClient
    ];
  }
