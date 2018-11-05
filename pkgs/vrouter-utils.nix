{ pkgs
, stdenv
, contrailVersion
, contrailBuildInputs
, contrailWorkspace
}:

stdenv.mkDerivation rec {
  name = "contrail-vrouter-utils-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  USER = "contrail";
  NIX_CFLAGS_COMPILE = "-I ${pkgs.libxml2.dev}/include/libxml2/";
  buildInputs = with pkgs; contrailBuildInputs ++ [ libpcap libnl ];
  buildPhase = ''
    scons --optimization=production --root=./ vrouter/utils
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/production/vrouter/utils/usr/bin/* $out/bin/
  '';
}
