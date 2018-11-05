{ buildPythonPackage
, pythonPackages
, contrailVersion
, contrailPythonBuild }:

buildPythonPackage rec {
  pname = "pysandesh";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailPythonBuild}/production/tools/sandesh/library/python/";
  propagatedBuildInputs = with pythonPackages; [ gevent netaddr ];
}
