{ pkgs
, lib
, buildPythonPackage
, contrailPythonBuild
, contrailVersion
, gevent
, kazoo
, pysandesh
, pycassa
, consistent_hash
}:

with pkgs.lib;

buildPythonPackage {
  pname = "libpartition";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/libpartition";
  doCheck = false;
  propagatedBuildInputs = [ kazoo gevent pysandesh pycassa consistent_hash ];
}
