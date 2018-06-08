{ pkgs }:

let

  neutronLib = pkgs.fetchgit {
    url = "https://git.openstack.org/openstack/neutron-lib";
    rev = "refs/tags/1.15.0";
    sha256 = "0p3avg5fh58dl0jgzsidl6la802azvj6x7wca7asc66i9n9glxr6";
  };

  neutronConstants = pkgs.runCommand "neutronConstants" {} ''
    mkdir -p $out/neutron/common
    touch $out/neutron/__init__.py
    touch $out/neutron/common/__init__.py
    cp ${neutronLib}/neutron_lib/constants.py $out/neutron/common
    cat <<EOF > $out/setup.py
from setuptools import setup

setup(
    name='neutron',
    version='0.1dev',
    packages=['neutron', 'neutron.common'],
    long_description="Neutron constants package"
)
EOF
  '';

in

  with pkgs.python27Packages; buildPythonPackage rec {
    pname = "neutron";
    version = "0.1dev";
    name = "${pname}-${version}";
    src = neutronConstants;
    doCheck = false;
  }
