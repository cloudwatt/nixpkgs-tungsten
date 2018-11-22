{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/collector.log
    use_syslog = 1

    cassandra_server_list = 127.0.0.1:9042

    [COLLECTOR]
    port=8086
    server=0.0.0.0

    [DISCOVERY]
    port = 5998
    server = 127.0.0.1

    [REDIS]
    port=6379
    server=127.0.0.1

    [API_SERVER]
    api_server_list = 127.0.0.1:8082
  '';
}
