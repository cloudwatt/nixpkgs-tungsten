{ pkgs
, stdenv
, deps
, contrailVersion
, contrailWorkspace
}:

stdenv.mkDerivation rec {
  name = "contrail-vrouter-utils-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 flex_2_5_35 bison
    deps.boost
    libpcap libnl
  ];
  USER = "contrail";
  NIX_CFLAGS_COMPILE = "-I ${pkgs.libxml2.dev}/include/libxml2/";
  buildPhase = ''
    scons --optimization=production --root=./ vrouter/utils
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/production/vrouter/utils/usr/bin/* $out/bin/
  '';
}
