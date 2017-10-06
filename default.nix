{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  controller = import ./controller.nix {inherit pkgs;};
  webui = import ./webui.nix {inherit pkgs;};
  deps = import ./deps.nix {inherit pkgs;};
  vms = import ./tools/build-vms.nix {pkgs_path = nixpkgs;};
in {
  contrail32 = with controller; with webui; with deps; {
    inherit contrailApi contrailControl contrailVrouterAgent
            # This is not a derivation.
            contrailVrouter
            contrailCollector contrailAnalyticsApi contrailDiscovery
            contrailQueryEngine
            contrailConfigUtils contrailVrouterUtils # contrailApiCli
            contrailVrouterNetns contrailVrouterPortControl
            webCore;
    };
  test = {
    contrail = import ./test/test.nix { inherit pkgs; pkgs_path = nixpkgs; };
    webui  = import ./test/webui.nix { inherit pkgs; pkgs_path = nixpkgs; };
  };
    inherit vms;
  }
