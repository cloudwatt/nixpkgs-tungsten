{ pkgs
, lib
, buildPythonPackage
, requests
, gevent
, contrailPythonBuild
, contrailVersion
}:

with pkgs.lib;

buildPythonPackage {
  pname = "vnc_api";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/api-lib";
  doCheck = false;
  propagatedBuildInputs = [ requests ] ++ optionals lib.versionAtLeast50 [ gevent ];
}
