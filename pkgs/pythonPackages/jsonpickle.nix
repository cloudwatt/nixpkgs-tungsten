{ buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "jsonpickle";
  version = "0.9.4";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0f7rs3v30xhwdmnqhqn9mnm8nxjq3yhp6gdzkg3z8m8lynhr968x";
  };
}
