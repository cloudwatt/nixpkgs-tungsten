{ pkgs
, lib
, buildPythonPackage
, psutil
, geventhttpclient
, bottle
, bitarray
, sqlalchemy
, contrailPythonBuild
, contrailVersion
}:

with pkgs.lib;

buildPythonPackage {
  pname = "cfgm_common";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/config/common";
  doCheck = false;
  propagatedBuildInputs = [ psutil geventhttpclient bottle bitarray ]
    ++ optionals lib.versionAtLeast41 [ sqlalchemy ];
}
