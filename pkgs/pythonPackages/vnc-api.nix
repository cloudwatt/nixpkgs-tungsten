{ buildPythonPackage
, requests
, contrailPythonBuild
, contrailVersion }:

buildPythonPackage {
  pname = "vnc_api";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/api-lib";
  doCheck = false;
  propagatedBuildInputs = [ requests ];
}
