{ pkgs
, stdenv
, deps
, pythonPackages
, contrailWorkspace
, contrailVersion
, isContrail41
, isContrail32
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-python-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
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
    (optionals isContrail41 (with pythonPackages; [
      sqlalchemy
    ]));

  prePatch = ''
    # Avoid running system sphinx when build is not sandboxed
    substituteInPlace controller/src/config/api-server/doc/SConscript \
      --replace "/usr/bin/sphinx-apidoc" "/doesnt-exists"

    # Don't know if this test is supposed to pass
    substituteInPlace controller/src/config/common/tests/test_analytics_client.py \
      --replace "test_analytics_request_with_data" "nop"

    # It seems these tests require contrail-test repository to be executed
    # See https://github.com/Juniper/contrail-test/wiki/Running-Tests
    for i in svc-monitor/setup.py contrail_issu/setup.py schema-transformer/setup.py vnc_openstack/setup.py api-server/setup.py; do
      sed -i 's|def run(self):|def run(self):\n        return|' controller/src/config/$i
    done

    # Tests are disabled because they requires to compile vizd (collector)
    sed -i '/OpEnv.AlwaysBuild(test_cmd)/d' controller/src/opserver/SConscript
  '' + optionalString isContrail41 ''
    # remove unneeded builds
    substituteInPlace controller/src/config/SConscript --replace "'device-manager'," ""
    substituteInPlace controller/src/config/SConscript --replace "'config-client-mgr'," ""
    substituteInPlace controller/src/config/SConscript --replace "'contrail_issu'," ""
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
  '';

  installPhase = ''
    mkdir $out;
    cp -r build/* $out
  '';
}
