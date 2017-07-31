{ pkgs ? import <nixpkgs> {} }:

let
  images = import ./image.nix {};
  controller = import ./controller.nix {};
in
  with controller; {
    inherit contrailApi contrailControl contrailVrouterAgent
            contrailCollector contrailAnalyticsApi contrailDiscovery
	    contrailVrouter;
  } //
  { images = images; }
