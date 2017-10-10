{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
}:

let
  pkgs = import nixpkgs {};
  allPackages = pkgs.lib.fix (import ./all-packages.nix {inherit pkgs;});
  vms = import ./tools/build-vms.nix {pkgs_path = nixpkgs;};
in {
  contrail32 = with allPackages.contrail32; with webui; {
    inherit api control vrouterAgent
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
