{ pkgs
  # This is used by tests
, nixpkgs
}:

self:
let callPackage = pkgs.lib.callPackageWith self;
in
{
  # This is to allow callPackage to fill pkgs
  inherit pkgs;

  contrailVersion = self.contrailMaster;
  contrail32 = "R3.2";
  contrailMaster = "master";
  isContrailMaster = self.contrailVersion == self.contrailMaster;
  isContrail32 = self.contrailVersion == self.contrail32;

  deps = import ./pkgs/deps.nix { inherit pkgs; };

  sources = import ./sources.nix { inherit pkgs; };

  contrailBuildInputs = with pkgs; [
    scons gcc5 pkgconfig autoconf automake libtool flex_2_5_35 bison
    # Global build deps
    libkrb5 openssl libxml2 perl tbb curl
    # This overriding should be avoided by patching log4cplus to
    # support older compilers.
    (log4cplus.override{stdenv = pkgs.overrideCC stdenv gcc5;})
    (boost155.override{stdenv = pkgs.overrideCC stdenv gcc5;})

    # api-server
    pythonPackages.lxml pythonPackages.pip
    # To get xxd binary required by sandesh
    vim
    # vrouter-agent
    libipfix
    # analytics
    protobuf2_5 self.deps.cassandra-cpp-driver
    rdkafka # should be > 0.9
    python zookeeper_mt pythonPackages.sphinx
  ];

  thirdPartyCache = callPackage ./pkgs/third-party-cache.nix { };
  thirdParty = callPackage ./pkgs/third-party.nix { };
  sandesh = callPackage ./pkgs/sandesh.nix { };
  controller = callPackage ./pkgs/controller.nix { };
  workspace = callPackage ./pkgs/workspace.nix { };

  vrouterAgent = callPackage ./pkgs/vrouter-agent.nix { };
  control = callPackage ./pkgs/control.nix { };
  collector = callPackage ./pkgs/collector.nix { };

  test = {
    allInOne = import ./test/all-in-one.nix { inherit pkgs; pkgs_path = nixpkgs; contrailPkgs = self; };
    webui  = import ./test/webui.nix { inherit pkgs; pkgs_path = nixpkgs; contrailPkgs = self; };
  };

  vms = import ./tools/build-vms.nix {contrailPkgs = self; pkgs_path = nixpkgs;};
}
//  
(with self; import ./pkgs/contrail.nix { inherit pkgs workspace deps contrailBuildInputs isContrail32 isContrailMaster; })
//
(with self; import ./pkgs/webui.nix {inherit pkgs sources;})
