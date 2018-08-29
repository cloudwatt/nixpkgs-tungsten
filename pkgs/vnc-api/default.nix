{ contrailPython, contrailVersion
, buildPythonPackage, requests }:

buildPythonPackage {
  pname = "vnc_api";
  version = contrailVersion;
  src = "${contrailPython}/production/api-lib";
  doCheck = false;
  propagatedBuildInputs = [ requests ];
}
