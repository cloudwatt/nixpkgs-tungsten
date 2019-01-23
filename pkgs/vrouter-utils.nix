{ pkgs
, stdenv
, contrailVersion
, contrailWorkspace
, boost
}:

stdenv.mkDerivation rec {
  name = "contrail-vrouter-utils-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 flex_2_5_35 bison
    boost libpcap libnl
  ];
  USER = "contrail";
  prePatch = ''
    sed -i "s!'/usr/include/libxml2',!'${pkgs.libxml2.dev}/include/libxml2',!" vrouter/utils/vtest/SConscript
  '';
  buildPhase = ''
    scons --optimization=production --root=./ vrouter/utils
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/production/vrouter/utils/usr/bin/* $out/bin/
  '';
}
