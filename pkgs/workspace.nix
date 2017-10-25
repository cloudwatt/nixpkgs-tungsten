{pkgs, sources, contrailBuildInputs, thirdParty, sandesh, controller }:

pkgs.stdenv.mkDerivation rec {
  name = "contrail-workspace";
  version = "3.2";

  phases = [ "unpackPhase" "patchPhase" "configurePhase" "installPhase" ];

  buildInputs = contrailBuildInputs;

  # We don't override the patchPhase to be nix-shell compliant
  preUnpack = ''mkdir workspace || exit; cd workspace'';
  srcs = [ sources.build thirdParty sources.generateds sandesh sources.vrouter sources.neutronPlugin controller ];
  sourceRoot = ''./'';
  postUnpack = ''
    cp ${sources.build.out}/SConstruct .

    mkdir tools
    mv ${sources.build.name} tools/build
    mv ${sources.generateds.name} tools/generateds
    mv ${sandesh.name} tools/sandesh

    [[ ${controller.name} != controller ]] && mv ${controller.name} controller
    [[ ${thirdParty.name} != third_party ]] && mv ${thirdParty.name} third_party
    find third_party -name configure -exec chmod 755 {} \;
    [[ ${sources.vrouter.name} != vrouter ]] && mv ${sources.vrouter.name} vrouter

    mkdir openstack
    mv ${sources.neutronPlugin.name} openstack/neutron_plugin
  '';

  prePatch = ''
    # Should be moved in build drv
    sed -i 's|def UseSystemBoost(env):|def UseSystemBoost(env):\n    return True|' -i tools/build/rules.py

    sed -i 's|--proto_path=/usr/|--proto_path=${pkgs.protobuf2_5}/|' tools/build/rules.py

    # GenerateDS crashes woth python 2.7.14 while it works with python 2.7.13
    # See https://bugs.launchpad.net/opencontrail/+bug/1721039
    sed -i 's/        parser.parse(infile)/        parser.parse(StringIO.StringIO(infile.getvalue()))/' tools/generateds/generateDS.py
      
  '';
  installPhase = "mkdir $out; cp -r ./ $out";
}
