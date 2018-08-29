{ contrailVersion, workspace
, buildPythonPackage, vnc_api, cfgm_common, python-neutronclient }:

buildPythonPackage {
    pname = "contrail-neutron-plugin";
    version = contrailVersion;
    src = "${workspace}/openstack/neutron_plugin";

    doCheck = false;
    prePatch = ''
      sed -i s/3.2.1/0/ requirements.txt;
    '';
    propagatedBuildInputs = [ vnc_api cfgm_common python-neutronclient ];
}
