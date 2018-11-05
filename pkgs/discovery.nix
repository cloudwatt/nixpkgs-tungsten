{ pythonPackages
, contrailVersion
, contrailPythonBuild
}:

pythonPackages.buildPythonApplication rec {
  name = "contrail-discovery-${version}";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/discovery/";
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
    gevent pycassa
    # Not in requirements.txt...
    cfgm_common vnc_api pysandesh sandesh_common xmltodict discovery_client
  ];
}
