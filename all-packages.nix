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
    libkrb5 openssl libxml2 perl curl
    # This overriding should be avoided by patching log4cplus to
    # support older compilers.
    (tbb.override{stdenv = pkgs.overrideCC stdenv gcc5;})
    (log4cplus.override{stdenv = pkgs.overrideCC stdenv gcc5;})
    (boost155.override{buildPackages.stdenv.cc = gcc5; stdenv = pkgs.overrideCC stdenv gcc5;})

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

  vrouterAgent = callPackage ./pkgs/vrouter-agent.nix { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc5; };
  control = callPackage ./pkgs/control.nix { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc5; };
  collector = callPackage ./pkgs/collector.nix { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc5; };
  queryEngine = callPackage ./pkgs/query-engine.nix { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc5; };
  lib.buildVrouter = callPackage ./pkgs/vrouter.nix { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc5; };
  keystonemiddleware = callPackage ./pkgs/keystonemiddleware { };

  test = {
    allInOne = callPackage ./test/all-in-one.nix { pkgs_path = nixpkgs; contrailPkgs = self; };
    # webui  = callPackage ./test/webui.nix { pkgs_path = nixpkgs; contrailPkgs = self; };
  };

  vms = callPackages ./tools/build-vms.nix { contrailPkgs = self; pkgs_path = nixpkgs;};

  tools.contrailIntrospectCli = callPackage ./tools/contrail-introspect-cli {};
  tools.contrailApiCliWithExtra = callPackage ./tools/contrail-api-cli { pkgs = pkgs // { contrailPkgs = self; }; };
  tools.gremlinConsole = callPackage ./tools/gremlin-console {};
  tools.gremlinServer = callPackage ./tools/gremlin-server { contrailPkgs = self; };
  tools.contrailGremlin = callPackage ./tools/contrail-gremlin {};
  tools.gremlinChecks = callPackage ./tools/contrail-gremlin/checks.nix { contrailPkgs = self; };
  tools.gremlinFsck = callPackage ./tools/contrail-gremlin/fsck.nix { contrailPkgs = self; };
} // (
  with self; import ./pkgs/contrail.nix {
    inherit pkgs workspace deps contrailBuildInputs isContrail32 isContrailMaster keystonemiddleware;
    stdenv = pkgs.overrideCC pkgs.stdenv gcc5;
  })
  # // (
  # with self; import ./pkgs/webui.nix {inherit pkgs sources;
  # })
