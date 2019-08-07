{ pkgs
, lib
, contrailVersion
, contrailSources
, contrailThirdPartyCache
}:

with pkgs.lib;

pkgs.stdenv.mkDerivation ({
  name = "contrail-third-party";
  version = contrailVersion;

  src = contrailSources.thirdParty;
  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];

  buildInputs = with pkgs; [
    pkgconfig autoconf automake libtool unzip contrailThirdPartyCache
  ] ++ (if lib.versionAtLeast50 then [ python3Packages.lxml cacert ] else [ pythonPackages.lxml wget ]);

  buildPhase = "python fetch_packages.py --cache-dir ${contrailThirdPartyCache}";

  installPhase = ''
    # Remove these useless libraries that increase the closure size
    rm -rf boost* icu curl* libxml2* log4cplus*

    mkdir $out
    cp -ra * $out/
  '';
} // optionalAttrs lib.versionAtLeast50 {

  patches = [ ./patches/R5.0-third_party_cache.patch ];

})
