{ pkgs
, buildPythonPackage
, setuptools
}:

# This version is required by contrail-api. With version 0.12.11,
# contrail-api fails to read any objects with a useless error
# message...
buildPythonPackage rec {
  version = "0.12.1";
  name = "bottle-${version}";
  src = pkgs.fetchurl {
    url = "mirror://pypi/b/bottle/${name}.tar.gz";
    sha256 = "1z16sydqgbn3dhbrz8afw5sd03ygdzq19cj2a140dxvpklqgcsn4";
  };
  propagatedBuildInputs = [ setuptools ];
}
