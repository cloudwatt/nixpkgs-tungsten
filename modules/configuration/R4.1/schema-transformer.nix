{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-schema-transformer.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/schema-transformer.log
    use_syslog = 1

    sandesh_send_rate_limit = 1000
    collectors = 127.0.0.1:8086
  '';
}
