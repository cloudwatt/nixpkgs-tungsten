{ pkgs }:

pkgs.writeTextFile {
  name = "contrail-api.conf";
  text = ''
    [DEFAULTS]
    log_file = /var/log/contrail/api.log
    log_level = SYS_DEBUG
    log_local = 1
    cassandra_server_list = localhost:9160
    disc_server_ip = localhost
    disc_server_port = 5998

    rabbit_port = 5672
    rabbit_server = localhost
    listen_port = 8082
    listen_ip_addr = 0.0.0.0
    zk_server_port = 2181
    zk_server_ip = localhost

    sandesh_send_rate_limit = 1000
    aaa_mode = no-auth

    [IFMAP_SERVER]
    ifmap_listen_ip = 0.0.0.0
    ifmap_listen_port = 8443
    ifmap_credentials = api-server:api-server
  '';
}
