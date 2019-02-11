{ pkgs
, lib
, stdenv
, contrailVersion
, contrailSources
, contrailThirdParty
, contrailController
, isContrail50
}:

with pkgs.lib;

stdenv.mkDerivation rec {
  name = "contrail-workspace";
  version = contrailVersion;
  srcs = with contrailSources;
    [ build contrailThirdParty sandesh vrouter neutronPlugin contrailController ]
    ++ optional lib.versionOlderThan50 contrailSources.generateds
    ++ optionals lib.versionAtLeast50 (with contrailSources; [ common analytics apiClient ]);
  sourceRoot = "./";
  # Add python to fix shebang in fixup phase
  buildInputs = with pkgs; [ python ];
  phases = [ "unpackPhase" "patchPhase" "configurePhase" "installPhase" "fixupPhase" ];
  # We don't override the patchPhase to be nix-shell compliant
  preUnpack = ''mkdir workspace || exit; cd workspace'';
  postUnpack = with contrailSources; ''
    cp ${build.out}/SConstruct .

    mkdir tools
    mv ${build.name} tools/build
    mv ${sandesh.name} tools/sandesh

    [[ ${contrailController.name} != controller ]] && mv ${contrailController.name} controller
    [[ ${contrailThirdParty.name} != third_party ]] && mv ${contrailThirdParty.name} third_party
    find third_party -name configure -exec chmod 755 {} \;
    [[ ${vrouter.name} != vrouter ]] && mv ${vrouter.name} vrouter

    mkdir openstack
    mv ${neutronPlugin.name} openstack/neutron_plugin
  '' + optionalString lib.versionOlderThan50 ''
    mv ${generateds.name} tools/generateds
  '' + optionalString lib.versionAtLeast50 ''
    mkdir src
    mv ${common.name} src/contrail-common
    mv ${analytics.name} src/contrail-analytics
    mv ${apiClient.name} src/contrail-api-client
  '';
  prePatch = ''
    # Should be moved in build drv
    sed -i 's|def UseSystemBoost(env):|def UseSystemBoost(env):\n    return True|' -i tools/build/rules.py

    sed -i 's|--proto_path=/usr/|--proto_path=${pkgs.protobuf2_5}/|' tools/build/rules.py

    # GenerateDS crashes woth python 2.7.14 while it works with python 2.7.13
    # See https://bugs.launchpad.net/opencontrail/+bug/1721039
    sed -i 's/        parser.parse(infile)/        parser.parse(StringIO.StringIO(infile.getvalue()))/' \
      ${if isContrail50 then "src/contrail-api-client/generateds/generateDS.py" else "tools/generateds/generateDS.py"}

    # setup scons cache
    sed -i "/rules.SetupBuildEnvironment/a env.CacheDir(\"cache\")" SConstruct
    mkdir -p cache
  '' + optionalString isContrail50 ''
    cd src/contrail-common && patch -p1 < ${./patches/R5.0-pysandesh-test-no-venv.patch} && cd ../..
  '';

  installPhase = ''
    mkdir $out
    cp -r ./ $out
  '';
}
