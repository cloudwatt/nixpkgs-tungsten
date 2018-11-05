{ pkgs
, pythonPackages
, contrailVersion
, contrailPythonBuild
, isContrail32
}:

pythonPackages.buildPythonApplication rec {
  name = "contrail-schema-transformer-${version}";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/config/schema-transformer/";
  # To be cleaned
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
    netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
    kazoo vnc_api sandesh_common kombu pyopenssl stevedore netifaces jsonpickle
  ] ++ (pkgs.lib.optional isContrail32  [ discovery_client ]);
}
