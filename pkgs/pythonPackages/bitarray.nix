{ buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "bitarray";
  version = "0.8.1";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "065bj29dvrr9rc47xkjalgjr8jxwq60kcfbryihkra28dqsh39bx";
  };
}
