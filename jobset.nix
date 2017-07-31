# This file defines derivations built by Hydra
with import ./deps.nix {};

let
  pkgs = import <nixpkgs> {};
  images = import ./image.nix {};
  controller = import ./controller.nix {};

  # We want that Hydra generate a link to be able to manually download the image
  dockerImageBuildProduct = image: pkgs.runCommand "${image.name}" {} ''
    mkdir $out
    ln -s ${image.out} $out/image.tar.gz
    mkdir $out/nix-support
    echo "file gzip ${image.out}" > $out/nix-support/hydra-build-products
  '';

  debianPackageBuildProduct = pkg:
    let
      name = pkgs.lib.removeSuffix ".deb" pkg.name + "-deb-bp";
    in
      pkgs.runCommand name {} ''
        mkdir $out
        ln -s ${pkg.out} $out/${pkg.name}
        mkdir $out/nix-support
        echo "file deb ${pkg.out}" > $out/nix-support/hydra-build-products
      '';

  mkDebianPackage = drv: pkgs.stdenv.mkDerivation rec {
    name = "${drv.name}.deb";
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ pkgs.dpkg ];
    src = controller.contrailVrouter;
    buildPhase = ''
      mkdir DEBIAN
      cat > DEBIAN/control <<EOF
      Package: ${drv.name}
      Architecture: all
      Version: ${drv.version}
      Provides: contrail-vrouter
      EOF
      dpkg-deb --build ./ ../package.deb
    '';
    installPhase = "cp ../package.deb $out";
  };

  dockerPushImage = image:
    let
      imageRef = "${image.imageName}:${image.imageTag}";
      registry = "localhost:5000";
      jobName = with pkgs.lib; "push-" + (removeSuffix ".tar" (removeSuffix ".gz" image.name));
    in
      pkgs.runCommand jobName {
      buildInputs = [ pkgs.jq skopeo ];
      } ''
      echo "Ungunzip image (since skopeo doesn't support tgz image)..."
      gzip -d ${image.out} -c > image.tar

      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry ${registry}/${imageRef} ..."
      skopeo --insecure-policy  copy --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://${registry}/${imageRef} > skipeo.log
      skopeo --insecure-policy inspect --tls-verify=false --cert-dir=/tmp docker://${registry}/${imageRef} > $out
    '';
in
  with controller; {
    inherit contrailApi contrailControl contrailVrouterAgent
            contrailCollector contrailAnalyticsApi contrailDiscovery
	    contrailVrouter;
  } //
  (pkgs.lib.mapAttrs (n: v: dockerImageBuildProduct v) images) //
  (pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair ("docker-push-" + n) (dockerPushImage v)) images) //
  {contrailVrouterDeb = debianPackageBuildProduct (mkDebianPackage controller.contrailVrouter);}
