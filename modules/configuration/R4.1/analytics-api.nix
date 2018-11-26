{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-analytics-api.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/analytics-api.log
    use_syslog = 1

    partitions = 0
    host_ip = 0.0.0.0
    collectors = 127.0.0.1:8086
    aaa_mode = no-auth
  '';
}
