{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.databaseLoader;

  # Some columns can have really big value...
  cqlshrc = pkgs.writeText "cqlshrc" ''
    [csv]
    field_size_limit = 1000000000
  '';
in {
  imports = [ ./cassandra.nix ];
  options = {
    contrail.databaseLoader = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      cassandraDumpPath = mkOption {
        type = types.path;
        description = "The path of the database dump folder";
      };
    };
  };

  config = {
    virtualisation = { memorySize = 8096; cores = 2; };
    cassandra = {
      enable = true;
      postStart = ''
        set -e
        cat ${cfg.cassandraDumpPath}/schema.cql | grep -v caching | sed "s|'replication_factor': '3'|'replication_factor': '1'|" | cqlsh
        for t in obj_uuid_table obj_fq_name_table; do
           # A bigger batch size fails on big Contrail databases
           echo "COPY config_db_uuid.$t FROM '${cfg.cassandraDumpPath}/config_db_uuid.$t.csv' WITH MAXBATCHSIZE = 2;" | cqlsh --cqlshrc=${cqlshrc}
        done
      '';
      };
  };
}
