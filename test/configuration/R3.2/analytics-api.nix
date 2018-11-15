{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-analytics-api.conf";
  text = ''
    [DEFAULTS]
    cassandra_server_list = 127.0.0.1:9042
    collectors = 127.0.0.1:8086

    aaa_mode = no-auth
    partitions = 0

    log_file = /var/log/contrail/analytic-api.log
    log_level = SYS_DEBUG
    log_local = 1

    [DISCOVERY]
    disc_server_ip = 127.0.0.1
    disc_server_port = 5998

    [REDIS]
    server = 127.0.0.1
    redis_server_port = 6379
    redis_query_port = 6379
  '';
}
