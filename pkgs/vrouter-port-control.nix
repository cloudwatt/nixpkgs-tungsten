{ pkgs
, pythonPackages
, contrailVersion
, contrailWorkspace
}:

let

  pythonPath = with pythonPackages; makePythonPath [ netaddr requests ];

in pkgs.stdenv.mkDerivation rec {
  name = "contrail-vrouter-port-control-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp controller/src/vnsw/agent/port_ipc/vrouter-port-control $out/bin
  '';
  postFixup = ''
    wrapProgram $out/bin/vrouter-port-control --prefix PYTHONPATH ":" ${pythonPath}
  '';
}
