# To create an image
# nix-build image.nix -o resul-image -A contrailApi
# docker load < result-image && docker run -d api-server

{ pkgs ? import <nixpkgs> {} }:

with import ./controller.nix { inherit pkgs; };

let 
  perp = pkgs.stdenv.mkDerivation {
    name = "perp";
    src = pkgs.fetchurl {
      url = http://b0llix.net/perp/distfiles/perp-2.07.tar.gz;
      sha256 = "05aq8xj9fpgs468dq6iqpkfixhzqm4xzj5l4lyrdh530q4qzw8hj";
    };
    preConfigure = "sed 's~ /usr/~ \${out}/usr/~' -i conf.mk";
  };

  genPerpRcMain = name: executable: pkgs.writeTextFile {
    name = "${name}-rc.main";
    executable = true;
    destination = "/etc/perp/${name}/rc.main";
    text = ''
      #!${pkgs.bash}/bin/bash

      exec 2>&1

      TARGET=$1
      SVNAME=$2

      start() {
        exec ${perp}/usr/sbin/runtool ${executable}
      }

      reset() {
        exit 0
      }

      eval $TARGET "$@"
    '';
  };

  perpEntryPoint = pkgs.writeScriptBin "entry-point" ''
    # Enable all perp services
    ${pkgs.findutils}/bin/find /etc/perp -type d -exec chmod +t {} \;
    ${perp}/usr/sbin/perpd
  '';

in {
  dockerContrailApi = pkgs.dockerTools.buildImage {
    name = "contrail-api";
    contents = [
      pkgs.coreutils
      (genPerpRcMain "contrail-api" "${contrailApi}/bin/contrail-api")
      # debug
      pkgs.nix pkgs.bash-completion pkgs.ncurses pkgs.bashInteractive pkgs.emacs25-nox
    ];
    config = {
      Cmd = [ "${pkgs.bash}/bin/bash"  "-c" "${perpEntryPoint}/bin/entry-point" ];
    };
  };
}
