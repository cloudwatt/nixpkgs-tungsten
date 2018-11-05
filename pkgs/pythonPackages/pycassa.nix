{ buildPythonPackage
, fetchPypi
, thrift
}:

buildPythonPackage rec {
  pname = "pycassa";
  version = "1.11.2";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1nsqjzgn6v0rya60dihvbnrnq1zwaxl2qwf0sr08q9qlkr334hr6";
  };
  # Tests are not executed since they require a cassandra up and
  # running
  doCheck = false;
  propagatedBuildInputs = [ thrift ];
}
