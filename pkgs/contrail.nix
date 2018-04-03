# Be careful, none of these derivations can be overriden!
#
# TODO: They should be moved to dedicated files and loaded by using to
# the callPackage pattern.

{pkgs, stdenv, workspace, deps, contrailBuildInputs, isContrail32, isContrailMaster, keystonemiddleware, contrailVersion }:

with deps;
with pkgs.lib;

rec {
  vnc_api = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "vnc_api";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/api-lib";
    doCheck = false;
    # buildInputs = [ pkgs.pythonPackages.fixtures ];
    propagatedBuildInputs = with pkgs.pythonPackages; [ requests];
  };

  vnc_openstack = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "vnc_openstack";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/config/vnc_openstack";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages;
      [ gevent requests bottle_0_12_1 netaddr cfgm_common pysandesh vnc_api keystonemiddleware ];
  };

  cfgm_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "cfgm_common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/config/common";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [ psutil geventhttpclient bottle_0_12_1 bitarray ] ++
      (optional isContrailMaster [ sqlalchemy ]);
  };

  sandesh_common = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "sandesh-common";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/sandesh/common/";
    propagatedBuildInputs = with pkgs.pythonPackages; [  ];
  };

  pysandesh = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "pysandesh";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/tools/sandesh/library/python/";

    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent netaddr ];
  };

  discovery_client = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "discovery-client";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/discovery/client/";
    propagatedBuildInputs = with pkgs.pythonPackages; [ gevent pycassa ];
  };

  contrailPython = stdenv.mkDerivation rec {
    name = "contrail-python";
    version = "3.2";
    src = workspace;
    USER="contrail";
    # Only required on master
    dontUseCmakeConfigure = true;

    buildInputs = with pkgs.pythonPackages; contrailBuildInputs ++
      # Used by python unit tests
      [ bitarray pbr funcsigs mock bottle ] ++
      (pkgs.lib.optional isContrailMaster [ pkgs.cmake pkgs."rabbitmq-c" pkgs.gperftools ]);
    propagatedBuildInputs = with pkgs.pythonPackages; [
      psutil geventhttpclient
    ];

    prePatch = ''
      # Don't know if this test is supposed to pass
      substituteInPlace controller/src/config/common/tests/test_analytics_client.py --replace "test_analytics_request_with_data" "nop"

      # It seems these tests require contrail-test repository to be executed
      # See https://github.com/Juniper/contrail-test/wiki/Running-Tests
      for i in svc-monitor/setup.py contrail_issu/setup.py schema-transformer/setup.py vnc_openstack/setup.py api-server/setup.py ${optionalString isContrailMaster "device-manager/setup.py"}; do
        sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/$i
      done

      # Tests are disabled because they requires to compile vizd (collector)
      sed -i '/OpEnv.AlwaysBuild(test_cmd)/d' controller/src/opserver/SConscript
    '' + (optionalString isContrailMaster ''
      substituteInPlace controller/src/config/common/setup.py --replace "test_suite='tests.test_suite'," ""
    '');


    buildPhase = ''
      export PYTHONPATH=$PYTHONPATH:controller/src/config/common/:build/production/config/api-server/vnc_cfg_api_server/gen/
      scons -j1 --optimization=production controller/src/config

      scons -j1 --optimization=production contrail-analytics-api
      ${optionalString isContrail32 "scons -j1 --optimization=production contrail-discovery"}
    '';
    installPhase = ''
    ${optionalString isContrailMaster "rm build/third_party/thrift/lib/cpp/.libs/concurrency_test"}
    mkdir $out; cp -r build/* $out'';
  };

  api =  pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-api-server-${version}";
    version = contrailVersion;
    src = "${contrailPython}/production/config/api-server/";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api vnc_openstack sandesh_common kombu pyopenssl stevedore netifaces keystonemiddleware
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  # Contains more than just the contrail-analytics-api!
  analyticsApi =  pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-analytics-api-${version}";
    version = contrailVersion;
    src = "${contrailPython}/production/opserver/";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
     lxml geventhttpclient psutil redis bottle_0_12_1 xmltodict sseclient pycassa requests prettytable
     # Not in requirements.txt...
     pysandesh cassandra-driver sandesh_common cfgm_common stevedore kafka vnc_api
    ] ++ (optional isContrail32  [ discovery_client ])
      ++ (optional (!isContrail32)  [ kazoo ]);
  };

  schemaTransformer =  pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-schema-transformer-${version}";
    version = contrailVersion;
    src = "${contrailPython}/production/config/schema-transformer/";
    # To be cleaned
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore netifaces jsonpickle
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  svcMonitor = pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-svc-monitor-${version}";
    version = contrailVersion;
    src = "${contrailPython}/noarch/config/svc-monitor/";
    doCheck = false;
    # FIXME: make tests pass
    prePatch = ''
      sed -i '/test_suite/d' setup.py
    '';
    propagatedBuildInputs = with pkgs.pythonPackages; [
      cfgm_common vnc_api pysandesh sandesh_common
      netaddr gevent kombu pyopenssl pyyaml kazoo mock lxml pycassa #FIXME: novaclient
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  discovery =  pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-discovery-${version}";
    version = contrailVersion;
    src = "${contrailPython}/production/discovery/";
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      gevent pycassa
      # Not in requirements.txt...
      cfgm_common vnc_api pysandesh sandesh_common xmltodict discovery_client
    ];
  };

  vrouterUtils = pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-utils-${version}";
    version = contrailVersion;
    src = workspace;
    USER="contrail";
    NIX_CFLAGS_COMPILE="-I ${pkgs.libxml2.dev}/include/libxml2/";
    buildInputs = pkgs.lib.remove pkgs.gcc contrailBuildInputs ++ [ pkgs.libpcap pkgs.libnl ];
    buildPhase = ''
      scons --optimization=production --root=./ vrouter/utils
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp build/production/vrouter/utils/usr/bin/* $out/bin/
    '';
  };

  configUtils = pkgs.stdenv.mkDerivation rec {
   name = "contrail-config-utils-${version}";
   version = contrailVersion;
   src = workspace;
   phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
   buildInputs = [
    (pkgs.python27.withPackages (pythonPackages: with pythonPackages; [
       netaddr vnc_api cfgm_common ]))
   ];
   installPhase = ''
     mkdir -p $out/bin
     cp controller/src/config/utils/*.{py,sh} $out/bin
   '';
  };

  vrouterPortControl = pkgs.stdenv.mkDerivation rec {
   name = "contrail-vrouter-port-control-${version}";
   version = contrailVersion;
   src = workspace;
   phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
   buildInputs = [
    (pkgs.python27.withPackages (pythonPackages: with pythonPackages; [
       netaddr requests ]))
   ];
   installPhase = ''
     mkdir -p $out/bin
     cp controller/src/vnsw/agent/port_ipc/vrouter-port-control $out/bin
   '';
  };

  vrouterApi = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "contrail-vrouter-api";
    version = "0";
    name = "${pname}-${version}";
    src = "${workspace}/controller/src/vnsw/contrail-vrouter-api/";
  };

  vrouterNetns =  pkgs.pythonPackages.buildPythonApplication rec {
    name = "contrail-vrouter-netns-${version}";
    version = contrailVersion;
    src = "${workspace}/controller/src/vnsw/opencontrail-vrouter-netns/";
    patchPhase = ''
      substituteInPlace requirements.txt --replace "docker-py" "docker"
      substituteInPlace opencontrail_vrouter_netns/lxc_manager.py --replace "dhclient" "${pkgs.dhcp}/bin/dhclient"
    '';
    # Try to access /var/log/contrail/contrail-lbaas-haproxy-stdout.log
    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [
      docker netaddr vrouterApi eventlet vnc_api cfgm_common
    ];
  };
}
