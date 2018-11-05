{ pkgs
, pythonPackages
, contrailVersion
, contrailPythonBuild
, isContrail32
}:

pythonPackages.buildPythonApplication rec {
  name = "contrail-svc-monitor-${version}";
  version = contrailVersion;
  src = "${contrailPythonBuild}/noarch/config/svc-monitor/";
  doCheck = false;
  # FIXME: make tests pass
  prePatch = ''
    sed -i '/test_suite/d' setup.py
  '';
  propagatedBuildInputs = with pythonPackages; [
    cfgm_common vnc_api pysandesh sandesh_common
    netaddr gevent kombu pyopenssl pyyaml kazoo mock lxml pycassa #FIXME: novaclient
  ] ++ (pkgs.lib.optional isContrail32  [ discovery_client ]);
}
