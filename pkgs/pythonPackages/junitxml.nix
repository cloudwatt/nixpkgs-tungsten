{ pkgs }:

pkgs.pythonPackages.buildPythonPackage rec {
  pname = "junitxml";
  version = "0.7";
  name = "${pname}-${version}";
  src = pkgs.pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "18xa3c5xhpjgmxynjp2rynrnk70jihv2f1zk3p8z7dvs0qki3455";
  };
}
