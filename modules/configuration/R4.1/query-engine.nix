{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-query-engine.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/query-engine.log
    use_syslog = 1

    collectors = 127.0.0.1:8086
    cassandra_server_list = 127.0.0.1:9042
  '';
}
