# Be careful, none of these derivations can be overriden!
#
# TODO: They should be moved to dedicated files and loaded by using to
# the callPackage pattern.

{ pkgs, workspace, deps, contrailBuildInputs, isContrail32, isContrailMaster }:

with deps;
with pkgs.lib;

rec {
  vnc_api = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "vnc_api";
    version = "0";
    name = "${pname}-${version}";
    src = "${contrailPython}/production/api-lib";
    propagatedBuildInputs = with pkgs.pythonPackages; [ requests ];
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

  contrailPython = pkgs.stdenv.mkDerivation rec {
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
    '';
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

  api =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-api-server";
    version = "3.2";
    src = "${contrailPython}/production/config/api-server/";
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore netifaces
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  # Contains more than just the contrail-analytics-api!
  analyticsApi =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-analytics-api";
    version = "3.2";
    src = "${contrailPython}/production/opserver/";
    prePatch = ''
      sed -i 's/sseclient/sseclient_py/' requirements.txt
    '';
    propagatedBuildInputs = with pkgs.pythonPackages; [
     lxml geventhttpclient psutil redis bottle_0_12_1 xmltodict sseclient pycassa requests prettytable
     # Not in requirements.txt...
     pysandesh cassandra-driver sandesh_common cfgm_common stevedore kafka vnc_api
    ] ++ (optional isContrail32  [ discovery_client ])
      ++ (optional (!isContrail32)  [ kazoo ]);
  };

  schemaTransformer =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-schema-transformer";
    version = "3.2";
    src = "${contrailPython}/production/config/schema-transformer/";
    # To be cleaned
    propagatedBuildInputs = with pkgs.pythonPackages; [
      netaddr psutil bitarray pycassa lxml geventhttpclient cfgm_common pysandesh
      kazoo vnc_api sandesh_common kombu pyopenssl stevedore netifaces jsonpickle
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  svcMonitor = pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-svc-monitor";
    version = "3.2";
    src = "${contrailPython}/noarch/config/svc-monitor/";
    # FIXME: make tests pass
    prePatch = ''
      sed -i '/test_suite/d' setup.py
    '';
    propagatedBuildInputs = with pkgs.pythonPackages; [
      cfgm_common vnc_api pysandesh sandesh_common
      netaddr gevent kombu pyopenssl pyyaml kazoo mock lxml pycassa #FIXME: novaclient
    ] ++ (optional isContrail32  [ discovery_client ]);
  };

  discovery =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-discovery";
    version = "3.2";
    src = "${contrailPython}/production/discovery/";
    propagatedBuildInputs = with pkgs.pythonPackages; [
      gevent pycassa
      # Not in requirements.txt...
      cfgm_common vnc_api pysandesh sandesh_common xmltodict discovery_client
    ];
  };

  vrouterUtils = pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-utils";
    version = "3.2";
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


  vrouter = kernelHeaders: pkgs.stdenv.mkDerivation rec {
    name = "contrail-vrouter-${kernelHeaders.name}";
    version = "3.2";
    src = workspace;
    USER="contrail";
    # Remove it when https://review.opencontrail.org/#/c/38139/ is merged
    patchPhase = optionalString isContrailMaster "cd vrouter; patch -p1 < ${../patches/0001-Fix-build-for-kernels-4.9.patch}; cd ..";
    # We switch to gcc 4.9 because gcc 5 is not supported before kernel 3.18
    buildInputs = pkgs.lib.remove pkgs.gcc contrailBuildInputs ++ [ pkgs.gcc49 ];
    buildPhase = ''
      export hardeningDisable=pic
      # To compile the module, we need the kernel sources and the kernel config
      kernelSrc=$(echo ${kernelHeaders}/lib/modules/*/build/)
      scons --optimization=production --kernel-dir=$kernelSrc vrouter/vrouter.ko
    '';
    installPhase = ''
      kernelVersion=$(ls ${kernelHeaders}/lib/modules/)
      mkdir -p $out/lib/modules/$kernelVersion/extra/net/vrouter/
      cp vrouter/vrouter.ko $out/lib/modules/$kernelVersion/extra/net/vrouter/
    '';
  };

  configUtils = pkgs.stdenv.mkDerivation rec {
   name = "contrail-config-utils";
   version = "3.2";
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
   name = "contrail-vrouter-port-control";
   version = "3.2";
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

  vrouterNetns =  pkgs.pythonPackages.buildPythonApplication {
    name = "contrail-vrouter-netns";
    version = "3.2";
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

  queryEngine = pkgs.stdenv.mkDerivation rec {
    name = "contrail-query-engine";
    version = "3.2";
    src = workspace;
    USER="contrail";
    buildInputs = contrailBuildInputs;
    buildPhase = ''
      scons -j1 --optimization=production contrail-query-engine
    '';
    installPhase = ''
      mkdir -p $out/{bin,etc/contrail}
      cp build/production/query_engine/qed $out/bin/
      cp ${workspace}/controller/src/query_engine/contrail-query-engine.conf $out/etc/contrail/
    '';
  };
}
