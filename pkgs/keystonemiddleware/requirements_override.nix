{ pkgs, python }:

# We use python libraries from nixpkgs in order ot avoid collision
# with contrail python dependencies.
self: super: with pkgs.pythonPackages; {
  inherit six pyparsing pbr certifi urllib3 netaddr stevedore netifaces chardet requests idna;
}
