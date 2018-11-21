{pkgs}:

pkgs.writeTextFile {
  name = "contrail-control.conf";
  text = ''
    [DEFAULT]
    log_level = SYS_INFO
    log_local = 0
    log_file = /var/log/contrail/control.log
    use_syslog = 1

    [IFMAP]
    server_url= https://127.0.0.1:8443
    password = api-server
    user = api-server

    [DISCOVERY]
    port = 5998
    server = 127.0.0.1
  '';
}
