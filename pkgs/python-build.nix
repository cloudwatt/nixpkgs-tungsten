{ pkgs
, stdenv
, deps
, pythonPackages
, contrailWorkspace
, contrailVersion
, isContrailMaster
, isContrail32 }:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-python";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  # Only required on master
  dontUseCmakeConfigure = true;

  buildInputs =
    (with pkgs; [
      scons libxml2 flex_2_5_35 bison curl
      vim # to get xxd binary required by sandesh
      deps.boost deps.tbb deps.log4cplus
      breakpointHook
    ]) ++
    (with pythonPackages; [
      lxml
      bitarray pbr funcsigs mock bottle requests # for tests
    ]);

  propagatedBuildInputs = with pythonPackages; [
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
}
