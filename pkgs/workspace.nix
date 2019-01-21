{ pkgs
, isContrail32
, contrailVersion
, contrailSources
, contrailThirdParty
, contrailController
}:

pkgs.stdenv.mkDerivation rec {
  name = "contrail-workspace";
  version = contrailVersion;
  srcs = with contrailSources;
    [ build contrailThirdParty generateds sandesh vrouter neutronPlugin contrailController ]
    ++ pkgs.lib.optional (!isContrail32) [ sources.contrailCommon ];
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
    mv ${generateds.name} tools/generateds
    mv ${sandesh.name} tools/sandesh

    [[ ${contrailController.name} != controller ]] && mv ${contrailController.name} controller
    [[ ${contrailThirdParty.name} != third_party ]] && mv ${contrailThirdParty.name} third_party
    find third_party -name configure -exec chmod 755 {} \;
    [[ ${vrouter.name} != vrouter ]] && mv ${vrouter.name} vrouter

    mkdir openstack
    mv ${neutronPlugin.name} openstack/neutron_plugin
  '' +
  pkgs.lib.optionalString (!isContrail32) ''
    mkdir src
    mv ${contrailCommon.name} src/contrail-common
  '';
  prePatch = ''
    # Should be moved in build drv
    sed -i 's|def UseSystemBoost(env):|def UseSystemBoost(env):\n    return True|' -i tools/build/rules.py

    sed -i 's|--proto_path=/usr/|--proto_path=${pkgs.protobuf2_5}/|' tools/build/rules.py

    # GenerateDS crashes woth python 2.7.14 while it works with python 2.7.13
    # See https://bugs.launchpad.net/opencontrail/+bug/1721039
    sed -i 's/        parser.parse(infile)/        parser.parse(StringIO.StringIO(infile.getvalue()))/' tools/generateds/generateDS.py

    # setup scons cache
    sed -i "/rules.SetupBuildEnvironment/a env.CacheDir(\"cache\")" SConstruct
    mkdir -p cache
  '';
  installPhase = ''
    mkdir $out
    cp -r ./ $out
  '';
}
