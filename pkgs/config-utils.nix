{ pkgs
, stdenv
, pythonPackages
, vrouterUtils
, contrailVersion
, contrailWorkspace
}:

let

  pythonPath = with pythonPackages; makePythonPath [ netaddr vnc_api cfgm_common requests ];

in stdenv.mkDerivation rec {
  name = "contrail-config-utils-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  buildInputs = [ pkgs.makeWrapper ];

  patchPhase = ''
    sed -i 's!/usr/bin/vif!${vrouterUtils}/bin/vif!' controller/src/config/utils/provision_vgw_interface.py
    sed -i '/from vnc_api.*/d' controller/src/config/utils/provision_vgw_interface.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp controller/src/config/utils/*.{py,sh} $out/bin
  '';

  postFixup = ''
    for i in $(find $out/bin -type f -executable -name "*.py"); do
      wrapProgram $i --prefix PATH ":" "${pkgs.nettools}/bin" --prefix PYTHONPATH ":" ${pythonPath}
    done
  '';
}
