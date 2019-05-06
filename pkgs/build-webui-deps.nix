{ pkgs
, stdenv
, deps
, contrailSources
, lib
}:

let

  inherit (pkgs) makeWrapper cacert unzip curl rsync;
  inherit (deps) nodejs-4_x;
  inherit (lib) fetchPackages;

  webui-deps-rev = "${contrailSources.webuiThirdParty.rev}";
  webui-deps-file = "webui-deps-${webui-deps-rev}.tar.xz";
  webui-deps-url = "https://storage.fr1.cloudwatt.com/v1/AUTH_e1cd9b90abb840798055d37b29f1a7d2/nixpkgs-tungsten-webui/${webui-deps-file}";

  in

  # --- A NOTE on the Impurity of the webui dependencies and its workaround ---
  #
  # -- The Problem --
  #
  # Unfortunately the way in which the webui project fetches its dependencies is
  # completely non-deterministic in its output. This is mostly because of 2 things:
  #
  # 1. ancient npm version
  # 2. no package.json / lock file but independent `npm install` calls
  #
  # Updating npm and thus node is non-trivial and webui uses a lot of severly outdated packages
  # and also applies patches that inject contrail specific code in dependencies.
  #
  # -- The workaround --
  #
  # Since the deps required to build the webui cannot be put into a derivation the shell
  # expression below is provided to create a tarball. This tarball is then uploaded to an
  # object storage and is retrieved via `webui-thirdparty-deps` below.
  #
  # -- The workflow --
  #
  # If you need to update the webui using new sources you need to recreate the deps:
  #
  # $ nix-shell default.nix -A contrail50.lib.buildWebuiDeps
  #
  # This will create a `.tar.xz` in $PWD along with its sha256. Update the hash of
  # `webui-thirdparty-deps` below and upload the file to the object storage.

  pkgs.mkShell rec {
    buildInputs = [ fetchPackages rsync nodejs-4_x contrailSources.webuiThirdParty ];
    shellHook = ''
      OUT=$PWD/${webui-deps-file}
      BUILD_DIR=$(mktemp -d)
      cp -R ${contrailSources.webuiThirdParty}/* $BUILD_DIR
      pushd $BUILD_DIR>/dev/null

      mkdir .home
      export HOME=$(readlink -f .home)
      fetch_packages.py -f ./packages.xml

      patchShebangs ./node_modules
      tar cfJ $OUT --transform 's,^\.,webui-thirdparty-deps,' .

      popd >/dev/null
      echo -e "\n\n"
      ls $OUT
      nix-prefetch-url --type sha256 --unpack file://$OUT
      exit 0
    '';
  }
