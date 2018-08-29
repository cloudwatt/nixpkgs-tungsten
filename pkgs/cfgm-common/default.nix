{ contrailPython, contrailVersion
, buildPythonPackage, psutil, geventhttpclient, bottle, bitarray }:


buildPythonPackage {
  pname = "cfgm_common";
  version = contrailVersion;
  src = "${contrailPython}/production/config/common";
  doCheck = false;
  propagatedBuildInputs = [ psutil geventhttpclient bottle bitarray ];
}
