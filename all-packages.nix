{ pkgs
  # This is used by tests
, nixpkgs
}:

self:
let
  callPackage = pkgs.lib.callPackageWith self;
  callPackages = pkgs.lib.callPackagesWith self;
in
pkgs // {
  # This is to allow callPackage to fill pkgs
  inherit pkgs;

  deps = callPackage ./pkgs/deps.nix { };

  contrail32 = "R3.2";
  contrailMaster = "master";
  isContrailMaster = self.contrailVersion == self.contrailMaster;
  isContrail32 = self.contrailVersion == self.contrail32;

  sourcesMaster = callPackage ./sources.nix { };
  sources32 = callPackage ./sources-R3.2.nix { };

  # We use by default the master sources
  sources = self.sourcesMaster;
  contrailVersion = self.contrailMaster;

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
  controller = callPackage ./pkgs/controller.nix { };
  workspace = callPackage ./pkgs/workspace.nix { };

  vrouterAgent = callPackage ./pkgs/vrouter-agent.nix { };
  control = callPackage ./pkgs/control.nix { };
  collector = callPackage ./pkgs/collector.nix { };

  test = {
    allInOne = callPackage ./test/all-in-one.nix { pkgs_path = nixpkgs; contrailPkgs = self; };
    webui  = callPackage ./test/webui.nix { pkgs_path = nixpkgs; contrailPkgs = self; };
  };

  vms = callPackages ./tools/build-vms.nix { contrailPkgs = self; pkgs_path = nixpkgs;};

  tools.contrailIntrospectCli = callPackage ./tools/contrail-introspect-cli {};
  tools.contrailApiCliWithExtra = callPackage ./tools/contrail-api-cli {};
  tools.gremlinConsole = callPackage ./tools/gremlin-console {};
  tools.gremlinDump = callPackage ./tools/gremlin-dump {};
  tools.gremlinChecks = callPackage ./tools/gremlin-checks { contrailPkgs = self; };
}
//  
(with self; import ./pkgs/contrail.nix { inherit pkgs workspace deps contrailBuildInputs isContrail32 isContrailMaster; })
//
(with self; import ./pkgs/webui.nix {inherit pkgs sources;})
