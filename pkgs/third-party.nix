{pkgs, sources, thirdPartyCache }:

pkgs.stdenv.mkDerivation {
  name = "contrail-third-party";
  version = "3.2";

  src = sources.thirdParty;
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildInputs = with pkgs; [
    pythonPackages.lxml pkgconfig autoconf automake libtool unzip wget thirdPartyCache
  ];

  buildPhase = "python fetch_packages.py --cache-dir ${thirdPartyCache}";

  installPhase = ''
    # Remove these useless libraries that increase the closure size
    rm -rf boost_1_48_0 icu

    mkdir $out
    cp -ra * $out/
  '';
}
