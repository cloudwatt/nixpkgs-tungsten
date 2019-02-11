{ pkgs
, lib
, buildPythonPackage
, pythonPackages
, contrailVersion
, contrailPythonBuild
, bottle
}:

with pkgs.lib;

buildPythonPackage rec {
  pname = "pysandesh";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailPythonBuild}/production/tools/sandesh/library/python/";
  propagatedBuildInputs = with pythonPackages; [ gevent netaddr ] ++ optionals lib.versionAtLeast50 [ bottle ];
}
