{ buildPythonPackage
, vnc_api
, cfgm_common
, python-neutronclient
, contrailWorkspace
, contrailVersion
}:

buildPythonPackage {
  pname = "contrail-neutron-plugin";
  version = contrailVersion;
  src = "${contrailWorkspace}/openstack/neutron_plugin";
  doCheck = false;
  prePatch = ''
    sed -i s/3.2.1/0/ requirements.txt;
  '';
  propagatedBuildInputs = [ vnc_api cfgm_common python-neutronclient ];
}
