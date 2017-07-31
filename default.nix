{ pkgs ? import <nixpkgs> {} }:

let
  images = import ./image.nix {inherit pkgs;};
  debian = import ./debian.nix {inherit pkgs;};
  controller = import ./controller.nix {inherit pkgs;};
in
  with controller; {
    inherit contrailApi contrailControl contrailVrouterAgent
            contrailCollector contrailAnalyticsApi contrailDiscovery
	    contrailVrouter;
  } //
  { debian = debian; } //
  { images = images; }
