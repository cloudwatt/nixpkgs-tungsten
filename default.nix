{ bootstrap_pkgs ? import <nixpkgs> {}
, pkgs_path ? bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs";
    rev = "5575fd469d89a0bdc990ea5a75e32a565fd0a389";
    sha256 = "14vlm7rkj2wym7g90sacw5r0950awixkd0nk7qdy2iyp16y5sr4i";
  }
, pkgs ? import pkgs_path {}
}:

let
  images = import ./image.nix {inherit pkgs;};
  debian = import ./debian.nix {inherit pkgs;};
  controller = import ./controller.nix {inherit pkgs;};
  deps = import ./deps.nix {inherit pkgs;};
in
  with controller; with deps; {
    inherit contrailApi contrailControl contrailVrouterAgent
            contrailCollector contrailAnalyticsApi contrailDiscovery
	    contrailQueryEngine
	    contrailConfigUtils contrailVrouterUtils # contrailApiCli
	    contrailVrouterNetns;
  } //
  { debian = debian;
    images = images;
    test = { contrail = import ./test/test.nix { inherit pkgs pkgs_path; }; };
  }
