{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  allPackages = import ./all-packages.nix {inherit pkgs nixpkgs;};
  contrail32Pkgs =  pkgs.lib.fix allPackages;
in {
  contrail32 = with contrail32Pkgs; {
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
