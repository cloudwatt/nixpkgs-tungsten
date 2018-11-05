{ pkgs, python }:

self: super: with pkgs.pythonPackages; {
  # We use python libraries from nixpkgs in order ot avoid collision
  # with contrail python dependencies.
  inherit packaging six pyparsing  certifi urllib3 ipaddress enum34 chardet requests idna;

  "linecache2" = python.overrideDerivation super."linecache2" (old: {
    buildInputs = old.buildInputs ++ [ super."pbr" super."setuptools-scm" ];
  });

  "python-dateutil" = python.overrideDerivation super."python-dateutil" (old: {
    buildInputs = old.buildInputs ++ [ super."setuptools-scm" ];
  });

  "requestsexceptions" = python.overrideDerivation super."requestsexceptions" (old: {
    buildInputs = old.buildInputs ++ [ super."pbr" ];
  });

  "traceback2" = python.overrideDerivation super."traceback2" (old: {
    buildInputs = old.buildInputs ++ [ super."pbr" ];
  });

  "unittest2" = python.overrideDerivation super."unittest2" (old: {
    buildInputs = old.buildInputs ++ [ super."argparse" ];
  });

}
