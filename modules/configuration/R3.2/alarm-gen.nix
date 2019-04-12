{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-alarm-gen.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/alarm-gen.log
    use_syslog = 1

    collectors = 127.0.0.1:8086
    kafka_broker_list = 127.0.0.1:9092
    zk_list = 127.0.0.1:2181

    [CONFIGDB]
    rabbitmq_server_list = 127.0.0.1:5672
  '';
}
