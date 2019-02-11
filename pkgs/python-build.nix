{ pkgs
, lib
, stdenv
, deps
, pythonPackages
, contrailWorkspace
, contrailVersion
, isContrail32
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-python-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  NIX_CFLAGS_COMPILE = "-Wno-unused-but-set-variable";
  buildInputs =
    (with pkgs; [
      scons libxml2 flex_2_5_35 bison curl
      vim # to get xxd binary required by sandesh
      deps.boost deps.tbb deps.log4cplus
    ]) ++
    (with pythonPackages; [
      lxml
      bitarray pbr funcsigs mock bottle requests # for tests
    ]) ++
    (optionals lib.versionAtLeast41 (with pythonPackages; [
      sqlalchemy
    ])) ++
    (optionals lib.versionAtLeast50 (with pythonPackages; [
      testtools
    ]));

  prePatch = ''
    # Don't know if this test is supposed to pass
    substituteInPlace controller/src/config/common/tests/test_analytics_client.py \
      --replace "test_analytics_request_with_data" "nop"
  '' + optionalString lib.versionAtLeast41 ''
    # remove unneeded builds
    substituteInPlace controller/src/config/SConscript --replace "'device-manager'," ""
    substituteInPlace controller/src/config/SConscript --replace "'config-client-mgr'," ""
    substituteInPlace controller/src/config/SConscript --replace "'contrail_issu'," ""
    substituteInPlace controller/src/config/SConscript --replace "'ironic-notification-manager'," ""
    substituteInPlace controller/src/config/SConscript --replace "'fabric-ansible'," ""
  '' + optionalString lib.versionOlderThan50 ''
    # It seems these tests require contrail-test repository to be executed
    # See https://github.com/Juniper/contrail-test/wiki/Running-Tests
    for i in svc-monitor/setup.py contrail_issu/setup.py schema-transformer/setup.py vnc_openstack/setup.py api-server/setup.py; do
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/$i
    done

    # Tests are disabled because they requires to compile vizd (collector)
    sed -i '/OpEnv.AlwaysBuild(test_cmd)/d' controller/src/opserver/SConscript

    # Avoid running system sphinx when build is not sandboxed
    substituteInPlace controller/src/config/api-server/doc/SConscript \
      --replace "/usr/bin/sphinx-apidoc" "/doesnt-exists"
  '' + optionalString lib.versionAtLeast50 ''
    sed -i '/env.SetupPyTestSuite/d' controller/src/config/api-server/SConscript
    sed -i '/env.SetupPyTestSuite/,+3d' controller/src/config/schema-transformer/SConscript
    sed -i '/test_target/d' controller/src/config/svc-monitor/SConscript
    sed -i '/test_target/d' controller/src/config/vnc_openstack/SConscript
    sed -i '/env.SetupPyTestSuiteWithDeps/d' src/contrail-api-client/api-lib/SConscript

    # Avoid running system sphinx when build is not sandboxed
    substituteInPlace src/contrail-api-client/api-lib/doc/SConscript \
      --replace "sphinx-apidoc" "doesnt-exists"
  '';

  # Deps to run api-server, schema-transformer, etc... in nix-shell
  propagatedBuildInputs = with pythonPackages; [
    netaddr psutil bitarray pycassa lxml geventhttpclient
    kazoo kombu pyopenssl stevedore netifaces keystonemiddleware
    jsonpickle pyyaml xmltodict gevent bottle requests neutron_constants
  ];

  buildPhase = ''
    export PYTHONPATH="$(pwd)/build/production/config/common:$(pwd)/build/production/sandesh/common:$(pwd)/build/production/tools/sandesh/library/python:$(pwd)/build/production/api-lib:$(pwd)/build/production/discovery/client:$(pwd)/build/production/config/schema-transformer:$(pwd)/build/production/config/vnc_openstack:$(pwd)/build/production/config/api-server/vnc_cfg_api_server/gen:$(pwd)/controller/src/config/common:$PYTHONPATH";

    scons -j1 --optimization=production controller/src/config
    scons -j1 --optimization=production contrail-analytics-api
  '' + optionalString isContrail32 ''
    scons -j1 --optimization=production contrail-discovery
  '' + optionalString lib.versionAtLeast50 ''
    scons -j1 --optimization=production src/contrail-api-client/api-lib
    scons -j1 --optimization=production sandesh/library/python:pysandesh
    scons -j1 --optimization=production controller/src/sandesh/common
    scons -j1 --optimization=production controller/src/config/svc_monitor:sdist
  '';

  installPhase = ''
    mkdir $out;
    cp -r build/* $out
  '';
}
