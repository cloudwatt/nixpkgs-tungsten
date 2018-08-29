{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  allPackages = import ./all-packages.nix {inherit pkgs nixpkgs;};

  contrail32Pkgs =
    let f = self: super: {
      contrailVersion = self.contrail32;
      sources = super.sources32;
      thirdPartyCache = super.thirdPartyCache.overrideAttrs(oldAttrs:
        { outputHash = "1rvj0dkaw4jbgmr5rkdw02s1krw1307220iwmf2j0p0485p7d3h2"; });
    };
    in pkgs.lib.fix (pkgs.lib.extends f  allPackages);

  contrailPkgs = pkgs.lib.fix allPackages;
in {
  contrail32 = with contrail32Pkgs; {
    pythonPackages = pkgs.lib.filterAttrs (n: v: builtins.elem n [ "vnc_api" "cfgm_common" "contrailNeutronPlugin" ]) pythonPackages;
    inherit configUtils api discovery schemaTransformer svcMonitor
            control
            vrouterAgent vrouterUtils vrouterNetns vrouterPortControl
            collector analyticsApi queryEngine
            # webCore webController
            test
            vms;
    };
  # contrailMaster = with contrailPkgs; {
  #   inherit configUtils api svcMonitor schemaTransformer
  #           control
  #           vrouterAgent vrouterUtils vrouterNetns vrouterPortControl
  #           collector analyticsApi
  #           test;
  #   };

  # We have to find a better way to let tools independant of contrail
  tools = contrail32Pkgs.tools;
  }
