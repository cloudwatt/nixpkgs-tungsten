{ pkgs, cfg }:

pkgs.writeTextFile {
  name = "contrail-control.conf";
  text = ''
    [DEFAULT]
    log_level = ${cfg.logLevel}
    log_local = 0
    log_file = /var/log/contrail/control.log
    use_syslog = 1

    hostip = 0.0.0.0
    # FIXME: when 127.0.0.1:8086 it will not connect to collector :s
    collectors = 192.168.1.1:8086
  '';
}
