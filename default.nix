{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  allPackages = import ./all-packages.nix {inherit pkgs nixpkgs;};

  contrail32Pkgs =
    let f = self: super: {
      contrailVersion = self.contrail32;
      sources = import ./sources-R3.2.nix { inherit pkgs; };
      thirdPartyCache = super.thirdPartyCache.overrideAttrs(oldAttrs:
        { outputHash = "1rvj0dkaw4jbgmr5rkdw02s1krw1307220iwmf2j0p0485p7d3h2"; });
    };
    in pkgs.lib.fix (pkgs.lib.extends f  allPackages);

  contrailMasterPkgs = pkgs.lib.fix allPackages;
in {
  contrail32 = with contrail32Pkgs; {
    inherit configUtils api discovery schemaTransformer svcMonitor
            control
            vrouterAgent vrouterUtils vrouterNetns vrouterPortControl
            collector analyticsApi queryEngine
            webCore webController
            test
            vms;
    };
  contrailMaster = with contrailMasterPkgs; {
    inherit configUtils api svcMonitor
            control
            vrouterAgent vrouterUtils vrouterNetns vrouterPortControl
            collector analyticsApi
            test;
    };
  }
