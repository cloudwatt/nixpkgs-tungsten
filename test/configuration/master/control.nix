{pkgs}:

pkgs.writeTextFile {
  name = "contrail-control.conf";
  text = ''
    [DEFAULT]
    log_file = /var/log/contrail/control.log
    log_local = 1
    log_level = SYS_DEBUG
    collectors = 127.0.0.1:8086

    [CONFIGDB]
    rabbitmq_server_list = localhost:5672
    config_db_server_list = localhost:9042
  '';
}  
