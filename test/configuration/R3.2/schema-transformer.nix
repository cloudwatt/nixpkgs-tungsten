{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-schema-transformer.conf";
  text = ''
    [DEFAULTS]
    log_file = /var/log/contrail/schema.log
    log_local = 1
    log_level = SYS_DEBUG

    rabbit_port = 5672
    rabbit_server = localhost

    zk_server_port = 2181
    zk_server_ip = localhost

    cassandra_server_list = localhost:9160

    api_server_port = 8082
    api_server_ip = localhost

    disc_server_port = 5998
    disc_server_ip = localhost

    sandesh_send_rate_limit = 1000
  '';
}
