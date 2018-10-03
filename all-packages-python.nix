{ pkgs, workspace, contrailVersion, contrailPython, deps }:

let
  contrailPythonPackages = selfPython: superPython:
  {
    bottle = deps.bottle_0_12_1;
    python-neutronclient = selfPython.callPackage ./pkgs/python-neutronclient { };
    contrailNeutronPlugin = selfPython.callPackage ./pkgs/contrail-neutron-plugin { inherit contrailVersion workspace; };
    vnc_api = selfPython.callPackage ./pkgs/vnc-api { inherit contrailVersion contrailPython; };
    cfgm_common = selfPython.callPackage ./pkgs/cfgm-common { inherit contrailVersion contrailPython; bitarray = deps.bitarray; };
    gevent = superPython.gevent.overridePythonAttrs( old: rec {
      version = "1.2.2";
      src = selfPython.fetchPypi {
        inherit version;
        pname = old.pname;
        sha256 = "0bbbjvi423y9k9xagrcsimnayaqymg6f2dj76m9z3mjpkjpci4a7";
      };
    });
  };
in
# We don't use an override on the python package set because overrides
# are not composable yet: an override can not be overriden.
pkgs.lib.fix' (pkgs.lib.extends (contrailPythonPackages) pkgs.python27.pkgs.__unfix__)
