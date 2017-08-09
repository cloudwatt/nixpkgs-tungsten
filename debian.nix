{ pkgs ? import <nixpkgs> {} }:

let
  controller = import ./controller.nix { inherit pkgs; };
  deps = import ./deps.nix { inherit pkgs; };

  mkDebianPackage = drv: pkgs.stdenv.mkDerivation rec {
    name = "${drv.name}.deb";
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ pkgs.dpkg ];
    src = drv;
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
in
  { contrailVrouter = mkDebianPackage (controller.contrailVrouter deps.ubuntuKernelHeaders_3_13_0_83_generic); }
