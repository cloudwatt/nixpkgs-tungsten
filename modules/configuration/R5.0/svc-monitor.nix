{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-svc-monitor.conf";
  text = ''
    [DEFAULTS]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/svc-monitor.log
    use_syslog = 1

    collectors = 127.0.0.1:8086
    sandesh_send_rate_limit = 1000

    [SCHEDULER]
    analytics_server_list = 127.0.0.1:8081
    aaa_mode = no-auth
  '';
}
