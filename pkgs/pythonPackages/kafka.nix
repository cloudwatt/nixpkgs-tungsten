{ buildPythonPackage
, fetchPypi
, tox
}:

buildPythonPackage rec {
  pname = "kafka-python";
  version = "1.3.3";
  name = "${pname}-${version}";
  buildInputs = [ tox ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "0i1dia3kixrrxhfwwhhnwrqrvycgzim62n64pfxqzbxz14z4lza6";
  };
}
