{ pkgs }:

pkgs.pythonPackages.buildPythonPackage rec {
  pname = "flexmock";
  version = "0.10.2";
  name = "${pname}-${version}";
  src = pkgs.pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "0arc6njvs6i9v9hgvzk5m50296g7zy5m9d7pyb43vdsdgxrci5gy";
  };
}
