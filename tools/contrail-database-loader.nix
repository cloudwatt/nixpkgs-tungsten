# This build a NixOs VM that load a casssandra dump and start the
# contrail api
#
# To generate a dump directory, use the following script:
# mkdir -p /tmp/cassandra-dump
# cqlsh -e "DESC SCHEMA" > /tmp/cassandra-dump/schema.cql
# for t in obj_uuid_table obj_fq_name_table; do
#   echo "COPY config_db_uuid.$t TO '/tmp/cassandra-dump/config_db_uuid.$t.csv';" | cqlsh
# done

{ pkgs, contrailPkgs }:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  cassandraDumpPath = "/tmp/shared/cassandra-dump/";

  machine = { config, ...}: {
    imports = [
      ../modules/contrail-database-loader.nix
      ../modules/all-in-one.nix
    ];
    config = {
      _module.args = { inherit pkgs contrailPkgs; };

      contrail = {

        allInOne = {
          enable = true;
          vhostInterface = "eth1";
        };

        databaseLoader = {
          enable = true;
          inherit cassandraDumpPath;
        };

        api.waitFor = false;
        discovery.waitFor = false;

        vrouterAgent.autoStart = false;
        schemaTransformer.autoStart = false;
        svcMonitor.autoStart = false;
        analyticsApi.autoStart = false;
        collector.autoStart = false;
        queryEngine.autoStart = false;
        control.autoStart = false;

      };

    };
  };
  vm = (makeTest { name = "contrail-database-loader"; nodes = { inherit machine; }; testScript = ""; }).driver;
in
pkgs.writeScript "contrail-database-loader-start" ''
  if [ ! -d  /tmp/xchg-shared/cassandra-dump ]
  then
    CASSANDRA_IP=$1
    cat <<EOF
You must first create a dump directory /tmp/xchg-shared/cassandra-dump
that contains all required dump files

To create theses files:

  mkdir -p /tmp/cassandra-dump
  cqlsh $CASSANDRA_IP -e "DESC SCHEMA" > /tmp/cassandra-dump/schema.cql
  for t in obj_uuid_table obj_fq_name_table; do
    echo "COPY config_db_uuid.\$t TO '/tmp/cassandra-dump/config_db_uuid.\$t.csv';" | cqlsh $CASSANDRA_IP
  done

Optional tables:

  for t in useragent_keyval_table; do
    echo "COPY useragent.\$t TO '/tmp/cassandra-dump/useragent.\$t.csv';" | cqlsh $CASSANDRA_IP
  done

  for t in service_instance_table pool_table; do
    echo "COPY svc_monitor_keyspace.\$t TO '/tmp/cassandra-dump/svc_monitor_keyspace.\$t.csv';" | cqlsh $CASSANDRA_IP
  done

  for t in service_chain_uuid_table service_chain_ip_address_table service_chain_table route_target_table; do
    echo "COPY to_bgp_keyspace.\$t TO '/tmp/cassandra-dump/to_bgp_keyspace.\$t.csv';" | cqlsh $CASSANDRA_IP
  done

Then move /tmp/cassandra-dump to /tmp/xchg-shared/cassandra-dump
And replay this script
EOF
    exit 1
  fi
  QEMU_NET_OPTS="''${QEMU_NET_OPTS:-hostfwd=tcp::2222-:22}" ${vm}/bin/nixos-run-vms
''
