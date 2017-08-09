{ bootstrap_pkgs ? import <nixpkgs> {}
, pkgs ? import (bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b602082e079c391cde7ab5ac1075e2630ce90863";
    sha256 = "1zxkw60hwv7jdawsd6lch4gavhx2wkw91pyjc6lpdg7lmry7wmy4";
  }) {}
}:

let
  images = import ./image.nix {inherit pkgs;};
  debian = import ./debian.nix {inherit pkgs;};
  controller = import ./controller.nix {inherit pkgs;};
in
  with controller; {
    inherit contrailApi contrailControl contrailVrouterAgent
            contrailCollector contrailAnalyticsApi contrailDiscovery
	    contrailVrouter;
    debian = debian;
    images = images;
    test = { contrail = import ./test/test.nix { inherit pkgs; }; };
  }
