{ buildPythonPackage
, psutil
, geventhttpclient
, bottle
, bitarray
, contrailPythonBuild
, contrailVersion }:

buildPythonPackage {
  pname = "cfgm_common";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/config/common";
  doCheck = false;
  propagatedBuildInputs = [ psutil geventhttpclient bottle bitarray ];
}
