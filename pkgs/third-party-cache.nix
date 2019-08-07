{ pkgs
, lib
, contrailVersion
, contrailSources
}:

# Hack: we create this derivation to split the downloading from
# the autotool reconfiguration of thrift made by fetch_packages.
# Since we want to use http_proxy, we need to have a deterministic
# output path. However fetch_packages reconfigures thirft and the
# produced paths are really sensible to autotool versions (that come
# from nixpkgs).
pkgs.stdenv.mkDerivation {
  name = "contrail-third-party-cache";
  version = contrailVersion;

  src = contrailSources.thirdParty;
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  impureEnvVars = pkgs.stdenv.lib.fetchers.proxyImpureEnvVars;
  # We have to fix the output hash to be allowed to set impure env vars.
  # This is really shitty since the hash depends on the autotool version used by thrift.
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "0000000000000000000000000000000000000000000000000000";

  # Starting with contrail 5.0 fetch_packages.py uses python3 and native python
  # implementation to download packages
  buildInputs = with pkgs; [
    pkgconfig autoconf automake libtool unzip
  ] ++ (if lib.versionAtLeast50 then [ python3Packages.lxml cacert ] else [ wget pythonPackages.lxml ]);

  buildPhase = "mkdir cache; python fetch_packages.py --cache-dir $PWD/cache";
  installPhase = "mkdir $out; cp -ra cache/* $out/";
}
