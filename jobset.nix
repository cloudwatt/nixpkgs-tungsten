# This file defines derivations built by Hydra
#
# We take expressions from the default.nix that we manipulate a little bit.
# - we transform docker image expressions to jobs that expose that the build product
# - we add jobs to push docker images to the registry
# - we transform debian package expressions to jobs that expose that the build product

{ bootstrap_pkgs ? <nixpkgs>
, fetched ? import ./nixpkgs-fetch.nix { nixpkgs = bootstrap_pkgs; }
, nixpkgs ? fetched.pkgs
}:

with import ./deps.nix {};

let
  pkgs = import nixpkgs {};
  contrailPkgs = import ./default.nix { inherit nixpkgs; };

  debianPackageBuildProduct = pkg:
    let
      name = "debian-package-" + (pkgs.lib.removeSuffix ".deb" pkg.name);
    in
      pkgs.runCommand name {} ''
        mkdir $out
        ln -s ${pkg.out} $out/${pkg.name}
        mkdir $out/nix-support
        echo "file deb ${pkg.out}" > $out/nix-support/hydra-build-products
      '';

in
  contrailPkgs //
  { "debian" = pkgs.lib.mapAttrs (n: v: debianPackageBuildProduct v) contrailPkgs.debian;
    test = { contrail = import test/test.nix { inherit pkgs; }; };
  }
