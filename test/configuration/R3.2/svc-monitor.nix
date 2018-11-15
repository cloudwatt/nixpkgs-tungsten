{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-svc-monitor.conf";
  text = ''
    [DEFAULTS]
    rabbit_port = 5672
    rabbit_server = localhost

    log_file = /var/log/contrail/svc-monitor.log
    log_level = SYS_DEBUG
    log_local = 1

    zk_server_port = 2181
    zk_server_ip = 127.0.0.1
    cassandra_server_list = 127.0.0.1:9160
    collectors = 127.0.0.1:8086
    api_server_port = 8082
    api_server_ip = 127.0.0.1
    disc_server_port = 5998
    disc_server_ip = 127.0.0.1
    sandesh_send_rate_limit = 1000
  '';
}
