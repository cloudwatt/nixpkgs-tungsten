{ buildPythonPackage
, pythonPackages
, contrailVersion
, contrailPythonBuild
}:

buildPythonPackage rec {
  pname = "vnc_openstack";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailPythonBuild}/production/config/vnc_openstack";
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
    gevent requests bottle netaddr cfgm_common pysandesh vnc_api
    keystonemiddleware neutron_constants
  ];
}
