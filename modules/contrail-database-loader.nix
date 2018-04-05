{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  cfg = config.contrail.databaseLoader;
in {
  imports = [ ./cassandra.nix ./contrail-api.nix  ./contrail-schema-transformer.nix ];
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
      apiConfigFile = mkOption {
        type = types.path;
        description = "The contrail api file path";
      };
      schemaTransformerConfigFile = mkOption {
        type = types.path;
        description = "The contrail schema transformer file path";
      };
    };
  };

  config = rec {
    virtualisation = { memorySize = 1024; cores = 1; };
    services.zookeeper.enable = true;
    services.rabbitmq.enable = true;
    services.cassandra = {
      enable = true;
      postStart = ''
        cat ${cfg.cassandraDumpPath}/schema.cql | grep -v caching | sed "s|'replication_factor': '3'|'replication_factor': '1'|" | cqlsh
        for t in obj_uuid_table obj_fq_name_table; do
           echo "COPY config_db_uuid.$t FROM '${cfg.cassandraDumpPath}/config_db_uuid.$t.csv';" | cqlsh
        done
      '';
      };
    contrail.api = {
      enable = true;
      configFile = cfg.apiConfigFile;
    };
    contrail.schemaTransformer = {
      enable = true;
      configFile = cfg.schemaTransformerConfigFile;
    };
  };
}
