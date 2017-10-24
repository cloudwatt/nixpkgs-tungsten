{pkgs}:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_local = 1
    log_level = SYS_DEBUG
    log_file = /var/log/contrail/contrail-collector.log

    cassandra_server_list = localhost:9042
    zookeeper_server_list = localhost:5672

    [API_SERVER]
    api_server_list = 127.0.0.1:8082
  '';
}
