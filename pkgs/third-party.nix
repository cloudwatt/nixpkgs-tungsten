{ pkgs, contrailVersion, contrailSources, contrailThirdPartyCache }:

pkgs.stdenv.mkDerivation {
  name = "contrail-third-party";
  version = contrailVersion;

  src = contrailSources.thirdParty;
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildInputs = with pkgs; [
    pythonPackages.lxml pkgconfig autoconf automake libtool unzip wget contrailThirdPartyCache
  ];

  buildPhase = "python fetch_packages.py --cache-dir ${contrailThirdPartyCache}";

  installPhase = ''
    # Remove these useless libraries that increase the closure size
    rm -rf boost_1_48_0 icu

    mkdir $out
    cp -ra * $out/
  '';
}
