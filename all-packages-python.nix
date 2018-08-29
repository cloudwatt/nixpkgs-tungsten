{ pkgs, workspace, contrailVersion, contrailPython, deps }:

let
  contrailPythonPackages = selfPython: superPython:
  {
    bottle = deps.bottle_0_12_1;
    python-neutronclient = selfPython.callPackage ./pkgs/python-neutronclient { };
    contrailNeutronPlugin = selfPython.callPackage ./pkgs/contrail-neutron-plugin { inherit contrailVersion workspace; };
    vnc_api = selfPython.callPackage ./pkgs/vnc-api { inherit contrailVersion contrailPython; };
    cfgm_common = selfPython.callPackage ./pkgs/cfgm-common { inherit contrailVersion contrailPython; bitarray = deps.bitarray; };
  };
in
# We don't use an override on the python package set because overrides
# are not composable yet: an override can not be overriden.
pkgs.lib.fix' (pkgs.lib.extends (contrailPythonPackages) pkgs.python27.pkgs.__unfix__)
