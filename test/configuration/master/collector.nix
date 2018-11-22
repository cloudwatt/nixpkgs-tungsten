{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/collector.log
    use_syslog = 1

    cassandra_server_list = localhost:9042
    zookeeper_server_list = localhost:5672

    [API_SERVER]
    api_server_list = 127.0.0.1:8082
  '';
}
