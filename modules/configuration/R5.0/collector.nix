{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-collector.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/collector.log
    use_syslog = 1
  '';
}
