{ pkgs
, pythonPackages
, contrailVersion
, contrailPythonBuild
, isContrail32
}:

pythonPackages.buildPythonApplication rec {
  name = "contrail-api-server-${version}";
  version = contrailVersion;
  src = "${contrailPythonBuild}/production/config/api-server/";
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
    netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
    kazoo vnc_api vnc_openstack sandesh_common kombu pyopenssl stevedore netifaces
    keystonemiddleware
  ] ++ (pkgs.lib.optional isContrail32 [ discovery_client ]);
}
