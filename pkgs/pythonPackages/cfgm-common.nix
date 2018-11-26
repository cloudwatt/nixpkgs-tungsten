{ pkgs
, buildPythonPackage
, psutil
, geventhttpclient
, bottle
, bitarray
, sqlalchemy
, contrailPythonBuild
, contrailVersion
, isContrail41
}:

with pkgs.lib;

buildPythonPackage {
  pname = "cfgm_common";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/config/common";
  doCheck = false;
  propagatedBuildInputs = [ psutil geventhttpclient bottle bitarray ]
    ++ optionals isContrail41 [ sqlalchemy ];
}
