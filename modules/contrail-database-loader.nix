{ config, lib, pkgs, ... }:

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
      zookeeperDumpPath = mkOption {
        type = types.nullOr types.path;
        description = "The path of the snapshot dump folder";
        default = null;
      };
    };
  };

  config = {
    virtualisation = { memorySize = 8096; cores = 2; };
    cassandra = {
      enable = true;
      postStart = ''
        cat ${cfg.cassandraDumpPath}/schema.cql | grep -v caching | sed "s|'replication_factor': '3'|'replication_factor': '1'|" | cqlsh

        load_table() {
          k=$1
          t=$2
          if [ -f ${cfg.cassandraDumpPath}/$k.$t.csv ]; then
            echo "COPY $k.$t FROM '${cfg.cassandraDumpPath}/$k.$t.csv' WITH MAXBATCHSIZE = 50;" | cqlsh --cqlshrc=${cqlshrc}
          fi
        }

        declare -A keyspaces
        keyspaces[config_db_uuid]="obj_uuid_table obj_fq_name_table"
        keyspaces[to_bgp_keyspace]="service_chain_uuid_table service_chain_ip_address_table service_chain_table route_target_table"
        keyspaces[svc_monitor_keyspace]="service_instance_table pool_table"
        keyspaces[useragent]="useragent_keyval_table"

        for k in ''${!keyspaces[@]}
        do
          for t in ''${keyspaces[$k]}
          do
            load_table $k $t
          done
        done
      '';
    };
    services.zookeeper = {
      enable = true;
      dataDir = "/var/lib/zookeeper";
    };
    systemd.services.zookeeper = {
      preStart = optionalString (cfg.zookeeperDumpPath != null) ''
        mkdir -p /var/lib/zookeeper/version-2/
        [ "$(ls -A ${cfg.zookeeperDumpPath})" ] && cp ${cfg.zookeeperDumpPath}/* /var/lib/zookeeper/version-2/
        chown -R zookeeper:nogroup /var/lib/zookeeper/version-2/
      '';
    };
  };
}
