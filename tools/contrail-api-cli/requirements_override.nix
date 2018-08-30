{ pkgs, python }:

self: super: {
  "datrie" = python.overrideDerivation super."datrie" (old: {
    buildInputs = old.buildInputs ++ [ pkgs.pythonPackages."pytestrunner" ];
  });

  "gremlin-fsck" = pkgs.contrailPkgs.tools.gremlinFsck;

  "contrail-api-cli-extra" = python.overrideDerivation super."contrail-api-cli-extra" (old: {
    src = pkgs.fetchFromGitHub {
      owner = "cloudwatt";
      repo = "contrail-api-cli-extra";
      rev = "6b7d2c4e21b9668e483843e47aed55e223124b9c";
      sha256 = "18jwvxc5kzjswv4hia4yvhp26gfhgzd2gzx7idcz25sh0p6ldvc6";
    };
  });

  "contrail-api-cli-with-extra" = with self; let
      # I tryied to override contrail-api-cli attribute by adding
      # contrail-api-cli-extra in propagatedBuildInputs but entry
      # points were not correctly managed.
      drv = python.withPackages {inherit "contrail-api-cli" "contrail-api-cli-extra" "gremlin-fsck";};
      name = "contrail-api-cli-with-extra-" + (builtins.parseDrvName(self."contrail-api-cli".name)).version;
    in drv.interpreter.overrideAttrs (old: {
      inherit name;
      # We remove python interpreter in order since we are only
      # interested by the contrail-api-cli program.
      buildCommand = old.buildCommand + ''rm $out/bin/.python* $out/bin/python*'';
      });
}

