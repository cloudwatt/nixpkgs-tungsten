{ pkgs
, lib
, pythonPackages
, contrailVersion
, contrailWorkspace
, contrailPythonBuild
, isContrail32
, isContrail41
}:

with pkgs.lib;

let
  contrailPythonPackages = self: super:
    let
      callPackage = pkgs.lib.callPackageWith
        (self // { inherit pkgs lib contrailVersion contrailWorkspace
                           contrailPythonBuild pythonPackages isContrail41; });
    in {
      gevent = super.gevent.overridePythonAttrs(old: rec {
        version = "1.2.2";
        src = self.fetchPypi {
          inherit version;
          pname = old.pname;
          sha256 = "0bbbjvi423y9k9xagrcsimnayaqymg6f2dj76m9z3mjpkjpci4a7";
        };
      });
      kombu = super.kombu.overridePythonAttrs(old: rec {
        version = "3.0.34";
        src = self.fetchPypi {
          inherit version;
          pname = old.pname;
          sha256 = "1nkm03cfv83rc2b79ngbyig12w1x2vms7942jrlb51lxn0czyy48";
        };
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.anyjson super.redis ];
      });
      amqp = super.amqp.overridePythonAttrs(old: rec {
        version = "1.4.9";
        src = self.fetchPypi {
          inherit version;
          pname = old.pname;
          sha256 = "06n6q0kxhjnbfz3vn8x9yz09lwmn1xi9d6wxp31h5jbks0b4vsid";
        };
      });
      bottle = callPackage ./bottle.nix { };
      kafka = callPackage ./kafka.nix { };
      # Theses weren't used before
      # sseclient = callPackage ./sseclient.nix { };
      # jsonpickle = callPackage ./jsonpickle.nix { };
      bitarray = callPackage ./bitarray.nix { };
      flexmock = callPackage ./flexmock.nix { };
      junitxml = callPackage ./junitxml.nix { };
      keystonemiddleware = callPackage ./keystonemiddleware { };
      neutron_constants = callPackage ./neutron_constants { };
      python-neutronclient = callPackage ./python-neutronclient { };
      python-novaclient = callPackage ./python-novaclient { };
      contrail_neutron_plugin = callPackage ./contrail-neutron-plugin.nix { };
      contrail_vrouter_api = callPackage ./vrouter-api.nix { };
      vnc_api = callPackage ./vnc-api.nix { };
      cfgm_common = callPackage ./cfgm-common.nix { };
      vnc_openstack = callPackage ./vnc-openstack.nix { };
      sandesh_common = callPackage ./sandesh-common.nix { };
      pysandesh = callPackage ./pysandesh.nix { };
    } // optionalAttrs isContrail32 {
      discovery_client = callPackage ./discovery-client.nix { };
    };
in
# We don't use an override on the python package set because overrides
# are not composable yet: an override can not be overriden.
pkgs.lib.fix' (pkgs.lib.extends contrailPythonPackages pkgs.python27.pkgs.__unfix__)
