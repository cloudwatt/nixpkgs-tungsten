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
  contrail32 = with controller; with webui; {
    inherit api control vrouterAgent
            # This is not a derivation.
            vrouter
            collector analyticsApi discovery
            queryEngine
            configUtils vrouterUtils # ApiCli
            vrouterNetns vrouterPortControl
            webCore;
    };
  test = {
    contrail = import ./test/test.nix { inherit pkgs; pkgs_path = nixpkgs; };
    webui  = import ./test/webui.nix { inherit pkgs; pkgs_path = nixpkgs; };
  };
    inherit vms;
  }
