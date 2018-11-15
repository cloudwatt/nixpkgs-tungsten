{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-query-engine.conf";
  text = ''
    [DEFAULT]
    log_file = /var/log/contrail/query-engine.log
    log_level = SYS_DEBUG
    log_local = 1
    cassandra_server_list = 127.0.0.1:9042
    [DISCOVERY]
    server = 127.0.0.1
    port = 5998
    [REDIS]
    server = 127.0.0.1
    port = 6379
  '';
}
