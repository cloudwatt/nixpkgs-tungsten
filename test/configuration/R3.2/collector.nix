{pkgs}:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_local = 1
    log_level = SYS_DEBUG
    log_file = /var/log/contrail/contrail-collector.log
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
