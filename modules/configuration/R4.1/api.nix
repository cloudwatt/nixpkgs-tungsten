{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-api.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/api.log
    use_syslog = 1

    listen_port = 8082
    listen_ip_addr = 0.0.0.0

    cassandra_server_list = 127.0.0.1:9160
    collectors = 127.0.0.1:8086
    rabbit_server = 127.0.0.1
    rabbit_port = 5672
    zk_server_ip = 127.0.0.1
    zk_server_port = 2181

    sandesh_send_rate_limit = 1000
    aaa_mode = no-auth
  '';
}
