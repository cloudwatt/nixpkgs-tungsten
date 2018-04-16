# To boot this image, the VM must have two interfaces. The second one
# is used by Contrail and must have the IP 192.168.1.3.

{ pkgs
, contrailPkgs, isContrail32, isContrailMaster
}:

let
  config = (
  import (pkgs.path + /nixos/lib/eval-config.nix) {
    system = "x86_64-linux";
    modules = [
      (pkgs.path + /nixos/maintainers/scripts/openstack/nova-image.nix)
      ../modules/all-in-one.nix
      ({ pkgs, lib, ... }: {
        _module.args = { inherit contrailPkgs isContrail32 isContrailMaster; };

        networking.hostName = "machine";
        # A workaround because some Contrail services are started too early and fail with
        # Apr 24 16:06:23 machine contrailCollector-start[1535]: Error! Cannot resolve host machineto a valid IP address
        networking.extraHosts = "127.0.0.1 machine";

        contrail.allInOne = {
          enable = true;
          contrailInterfaceIp="192.168.1.3";
        };
      })];
  }).config;
in
  config.system.build.novaImage
