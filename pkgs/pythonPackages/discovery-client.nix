{ buildPythonPackage
, pythonPackages
, contrailVersion
, contrailPythonBuild
}:

buildPythonPackage rec {
  pname = "discovery-client";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailPythonBuild}/production/discovery/client/";
  propagatedBuildInputs = with pythonPackages; [ gevent pycassa ];
}
