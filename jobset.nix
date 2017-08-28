# This file defines derivations built by Hydra
#
# We take expressions from the default.nix that we manipulate a little bit.
# - we transform docker image expressions to jobs that expose that the build product
# - we add jobs to push docker images to the registry
# - we transform debian package expressions to jobs that expose that the build product

with import ./deps.nix {};

let
  pkgs = import <nixpkgs> {};
  contrailPkgs = import ./default.nix { inherit pkgs; };

  # We want that Hydra generate a link to be able to manually download the image
  dockerImageBuildProduct = image: pkgs.runCommand "${image.name}" {} ''
    mkdir $out
    ln -s ${image.out} $out/image.tar.gz
    mkdir $out/nix-support
    echo "file gzip ${image.out}" > $out/nix-support/hydra-build-products
  '';

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

  dockerPushImage = image:
    let
      imageRef = "${image.imageName}:${image.imageTag}";
      registry = "localhost:5000";
      jobName = with pkgs.lib; "push-" + (removeSuffix ".tar" (removeSuffix ".gz" image.name));
    in
      pkgs.runCommand jobName {
      buildInputs = with pkgs; [ jq skopeo ];
      } ''
      echo "Ungunzip image (since skopeo doesn't support tgz image)..."
      gzip -d ${image.out} -c > image.tar

      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry ${registry}/${imageRef} ..."
      skopeo --insecure-policy  copy --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://${registry}/${imageRef} > skipeo.log
      skopeo --insecure-policy inspect --tls-verify=false --cert-dir=/tmp docker://${registry}/${imageRef} > $out
    '';

    genDockerPushJobs = drvs:
      pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair ("docker-push-" + n) (dockerPushImage v)) drvs;
    genDockerImageBuildProduct = drvs:
      pkgs.lib.mapAttrs (n: v: dockerImageBuildProduct v) drvs;
in
  contrailPkgs //
  { "images" = genDockerImageBuildProduct contrailPkgs.images // (genDockerPushJobs contrailPkgs.images);
    "debian" = pkgs.lib.mapAttrs (n: v: debianPackageBuildProduct v) contrailPkgs.debian;
    test = { contrail = import test/test.nix { inherit pkgs; }; };
  }
