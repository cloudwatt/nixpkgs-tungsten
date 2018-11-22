{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-schema-transformer.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/schema-transformer.log
    use_syslog = 1

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
