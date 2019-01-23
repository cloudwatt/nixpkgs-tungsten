self: super:

with builtins;

let

  inherit (super) callPackage callPackages;
  inherit (super.lib) filterAttrs;

  addCacheOutput = drv: drv.overrideAttrs (old:
    let
      oldOutputs = if old ? "outputs" then old.outputs else [ "out" ];
    in {
      outputs = oldOutputs ++ [ "cache" ];
      installPhase = old.installPhase + ''
        mkdir -p $cache
        cp cache/config $cache/
        # keep only .o files from the cache
        find cache \
          -type f \
          -exec sh -c "${self.file}/bin/file {} | grep -v -q 'ELF 64-bit LSB relocatable'" \; \
          -delete
        cp -r cache/* $cache
      '';
    }
  );

  addShellHook = drv: drv.overrideAttrs (old:
    let
      oldShellHook = if old ? "shellHook" then old.shellHook else "";
    in {
      shellHook = oldShellHook + ''
        unpackPhase
        cd $sourceRoot
        rmdir cache
        ln -s ${drv.cache} cache
        alias scons="scons --cache-readonly"
        patchPhase
        echo "All set! To build run:"
        echo $buildPhase
      '';
    }
  );

  minimalDump = super.stdenv.mkDerivation {
    name = "minimal-cassandra-dump";
    src = ./test/minimal-cassandra-dump.tgz;
    setSourceRoot = "sourceRoot=`pwd`";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  stdenv_gcc5 = super.overrideCC self.stdenv self.gcc5;
  stdenv_gcc49 = super.overrideCC self.stdenv self.gcc49;
  stdenv_gcc6 = super.overrideCC self.stdenv self.gcc6;

  contrail = super.lib.makeScope super.newScope (lself: let

    callPackage = lself.callPackage;

  in {

    contrailSources = null;
    contrailVersion = null;

    isContrailMaster = lself.contrailVersion == "master";
    isContrail32 = lself.contrailVersion == "3.2";

    modules = ./modules;
    path = ./.;

    # build
    contrailThirdPartyCache = callPackage ./pkgs/third-party-cache.nix { };
    contrailThirdParty = callPackage ./pkgs/third-party.nix { };
    contrailController = callPackage ./pkgs/controller.nix { };
    contrailWorkspace = callPackage ./pkgs/workspace.nix { };
    contrailPythonBuild = addCacheOutput (callPackage ./pkgs/python-build.nix { stdenv = stdenv_gcc5; });

    lib = {
      buildVrouter = callPackage ./pkgs/vrouter.nix { stdenv = stdenv_gcc49; };
      # used for exposing to hydra
      sanitizeOutputs = contrailAttrs:
        let
          exclude = [
            "contrailSources"
            "contrailVersion"
            "contrailBuildInputs"
            "contrailThirdParty"
            "contrailThirdPartyCache"
            "contrailController"
            "contrailWorkspace"
            "contrailPythonBuild"
            "isContrail32"
            "isContrailMaster"
            "pythonPackages"
            "lib"
            "modules"
            "path"
            "dev"
            # added by makeScope
            "overrideScope'"
            "overrideScope"
            "callPackage"
            "newScope"
            "packages"
            # added by callPackage
            "override"
            "overrideDerivation"
          ];
          pythonPackages = [
            "contrail_neutron_plugin"
            "contrail_vrouter_api"
            "vnc_api"
            "cfgm_common"
            "vnc_openstack"
            "sandesh_common"
            "pysandesh"
            "discovery_client"
          ];
        in
          (filterAttrs (k: _: ! elem k exclude) contrailAttrs) // {
            pythonPackages = filterAttrs (k: _: elem k pythonPackages) contrailAttrs.pythonPackages;
          };
    };

    # deps
    cassandraCppDriver = callPackage ./pkgs/cassandra-cpp-driver.nix { stdenv = stdenv_gcc6; };
    libgrok = callPackage ./pkgs/libgrok.nix { };
    log4cplus = callPackage ./pkgs/log4cplus.nix { stdenv = stdenv_gcc5; };
    thrift = callPackage ./pkgs/thrift.nix { stdenv = stdenv_gcc5; };
    bind = callPackage ./pkgs/bind.nix { stdenv = stdenv_gcc5; };
    boost = self.boost155.override{
      buildPackages.stdenv.cc = self.gcc5;
      stdenv = stdenv_gcc5;
      enablePython = true;
    };
    tbb = (self.tbb.overrideAttrs(old: rec {
      name = "tbb-${version}";
      version = "2018_U5";
      src = lself.contrailThirdParty;
      sourceRoot = "./contrail-third-party/${name}";
    })).override {
      stdenv = stdenv_gcc5;
    };

    # vrouter
    vrouterAgent = addCacheOutput (callPackage ./pkgs/vrouter-agent.nix { stdenv = stdenv_gcc5; });
    vrouterUtils = addCacheOutput (callPackage ./pkgs/vrouter-utils.nix { });
    vrouterPortControl = callPackage ./pkgs/vrouter-port-control.nix { };
    vrouterNetNs = callPackage ./pkgs/vrouter-netns.nix { };
    vrouterModuleNixos_4_9 = addCacheOutput (lself.lib.buildVrouter self.linuxPackages_4_9.kernel.dev);

    # config
    discovery = callPackage ./pkgs/discovery.nix { };
    apiServer = callPackage ./pkgs/api-server.nix { };
    svcMonitor = callPackage ./pkgs/svc-monitor.nix { };
    schemaTransformer = callPackage ./pkgs/schema-transformer.nix { };
    configUtils = callPackage ./pkgs/config-utils.nix { };

    # control
    control = addCacheOutput (callPackage ./pkgs/control.nix { stdenv = stdenv_gcc5; });

    # analytics
    analyticsApi = callPackage ./pkgs/analytics-api.nix { };
    collector = addCacheOutput (callPackage ./pkgs/collector.nix { stdenv = stdenv_gcc5; });
    queryEngine = addCacheOutput (callPackage ./pkgs/query-engine.nix { stdenv = stdenv_gcc5; });

    pythonPackages = callPackage ./pkgs/pythonPackages { };

    dev = {
      vrouterUtils = addShellHook lself.vrouterUtils;
      vrouterAgent = addShellHook lself.vrouterAgent;
      queryEngine = addShellHook lself.queryEngine;
      collector = addShellHook lself.collector;
      control = addShellHook lself.control;
      vrouterModuleNixos_4_9 = addShellHook lself.vrouterModuleNixos_4_9;
      contrailPythonBuild = addShellHook lself.contrailPythonBuild;
    };

    test = {
      allInOne = callPackage ./test/all-in-one.nix { contrailPkgs = lself; };
      tcpFlows = callPackage ./test/flows.nix { contrailPkgs = lself; mode = "tcp"; };
      udpFlows = callPackage ./test/flows.nix { contrailPkgs = lself; mode = "udp"; };
      loadDatabase = callPackage ./test/load-database.nix {
        contrailPkgs = lself;
        cassandraDumpPath = minimalDump;
        extraTestScript = ''
          $machine->waitUntilSucceeds("contrail-api-cli ls -l virtual-network | grep -q vn1");
        '';
      };
      gremlinDump = callPackage ./test/gremlin-dump.nix { contrailPkgs = lself; cassandraDumpPath = minimalDump; };
    };

  });

in {

  contrail32 = contrail.overrideScope' (self: super: {
    contrailVersion = "3.2";
    contrailSources = callPackage ./sources-R3.2.nix { };
    contrailThirdPartyCache = super.contrailThirdPartyCache.overrideAttrs(oldAttrs:
      { outputHash = "1x0kgr2skq17lh5anwimlfjy1yzc8vhz5cmyraxg4hqig1g599sf"; });
    tools.databaseLoader = callPackage ./tools/contrail-database-loader.nix { contrailPkgs = self; };
  });

}
