{ pkgs
, pythonPackages
, contrailPythonBuild
, contrailVersion
, isContrail32
}:

with pkgs.lib;

# Contains more than just the contrail-analytics-api!
pythonPackages.buildPythonApplication rec {
  name = "contrail-analytics-api-${version}";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/opserver/";
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
   lxml geventhttpclient psutil redis bottle xmltodict sseclient pycassa requests prettytable
   # Not in requirements.txt...
   pysandesh cassandra-driver sandesh_common cfgm_common stevedore kafka vnc_api
  ] ++ (optional isContrail32  [ discovery_client ])
    ++ (optional (!isContrail32)  [ kazoo ]);
}
