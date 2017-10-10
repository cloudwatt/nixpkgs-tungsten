{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  allPackages = pkgs.lib.fix (import ./all-packages.nix {inherit pkgs nixpkgs;});
in {
  contrail32 = with allPackages.contrail32; with webui; {
    inherit api control vrouterAgent
            collector analyticsApi discovery
            queryEngine
            configUtils vrouterUtils
            vrouterNetns vrouterPortControl
            webCore
            test
            vms;
    };
  }
