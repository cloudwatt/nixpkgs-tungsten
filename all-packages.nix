{ pkgs
  # This is used by tests
, nixpkgs
}:

self: {
  deps = import ./deps.nix { inherit pkgs; };

  contrail32 = {
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
    "contrail-workspace" = with self.contrail32; import ./workspace.nix { inherit pkgs sources contrailBuildInputs; };
    sources = import ./sources.nix { inherit pkgs; };

    test = {
      allInOne = import ./test/test.nix { inherit pkgs; pkgs_path = nixpkgs; contrailPkgs = self.contrail32; };
      webui  = import ./test/webui.nix { inherit pkgs; pkgs_path = nixpkgs; contrailPkgs = self.contrail32; };
    };

    vms = import ./tools/build-vms.nix {contrailPkgs = self.contrail32; pkgs_path = nixpkgs;};

    }
    //
    (with self; with self.contrail32; import ./controller.nix { inherit pkgs contrail-workspace deps contrailBuildInputs; })
    //
    (with  self.contrail32; import ./webui.nix {inherit pkgs sources;});
}
