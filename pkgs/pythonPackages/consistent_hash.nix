{ buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "consistent_hash";
  version = "1.0";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "d9f88eff086680918b458b62994fbf07ef97736771f1e9f3b05855547636a7ac";
  };
  doCheck = false;
}
