{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/collector.log
    use_syslog = 1

    zookeeper_server_list = 127.0.0.1:2181
    kafka_broker_list = 127.0.0.1:9092
  '';
}
