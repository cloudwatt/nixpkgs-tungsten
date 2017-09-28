{ config, lib, pkgs, ... }:

with lib;

let
  webuiPkgs = import ../webui.nix { inherit pkgs; };
  cfg = config.contrail.webui;
  web-server = pkgs.writeTextFile {
    name = "contrail-web-server.js";
    text = ''
      var config = {};
      config.staticAuth = [
        {"username": "admin", "password": "admin"}
      ];
      config.multi_tenancy = {};
      config.multi_tenancy.enabled = false;
      config.orchestration = {};
      config.orchestration.Manager = 'none';
      config.serviceEndPointFromConfig = true;
      config.endpoints = {};
      config.endpoints.apiServiceType = 'ApiServer';
      config.endpoints.opServiceType = 'OpServer';
      config.regionsFromConfig = true;
      config.regions = {};
      config.regions.RegionOne = 'http://127.0.0.1:5000/v2.0';
      config.serviceEndPointTakePublicURL = true;
      config.networkManager = {};
      config.networkManager.ip = '127.0.0.1';
      config.networkManager.port = '9696'
      config.networkManager.authProtocol = 'http';
      config.networkManager.apiVersion = [];
      config.networkManager.strictSSL = false;
      config.networkManager.ca = "";
      config.imageManager = {};
      config.imageManager.ip = '127.0.0.1';
      config.imageManager.port = '9292';
      config.imageManager.authProtocol = 'http';
      config.imageManager.apiVersion = ['v1', 'v2'];
      config.imageManager.strictSSL = false;
      config.imageManager.ca = "";
      config.computeManager = {};
      config.computeManager.ip = '127.0.0.1';
      config.computeManager.port = '8774';
      config.computeManager.authProtocol = 'http';
      config.computeManager.apiVersion = ['v1.1', 'v2'];
      config.computeManager.strictSSL = false;
      config.computeManager.ca = "";
      config.identityManager = {};
      config.identityManager.ip = '127.0.0.1';
      config.identityManager.port = '5000';
      config.identityManager.authProtocol = 'http';
      config.identityManager.apiVersion = ['v2.0'];
      config.identityManager.strictSSL = false;
      config.identityManager.ca = "";
      config.storageManager = {};
      config.storageManager.ip = '127.0.0.1';
      config.storageManager.port = '8776';
      config.storageManager.authProtocol = 'http';
      config.storageManager.apiVersion = ['v1'];
      config.storageManager.strictSSL = false;
      config.storageManager.ca = "";
      config.cnfg = {};
      config.cnfg.server_ip = '127.0.0.1';
      config.cnfg.server_port = '8082';
      config.cnfg.authProtocol = 'http';
      config.cnfg.strictSSL = false;
      config.cnfg.ca = "";
      config.analytics = {};
      config.analytics.server_ip = '127.0.0.1';
      config.analytics.server_port = '8081';
      config.analytics.authProtocol = 'http';
      config.analytics.strictSSL = false;
      config.analytics.ca = "";
      config.vcenter = {};
      config.vcenter.server_ip = '127.0.0.1';         //vCenter IP
      config.vcenter.server_port = '443';             //Port
      config.vcenter.authProtocol = 'https';          //http or https
      config.vcenter.datacenter = 'vcenter';          //datacenter name
      config.vcenter.dvsswitch = 'vswitch';           //dvsswitch name
      config.vcenter.strictSSL = false;               //Validate the certificate or ignore
      config.vcenter.ca = "";                         //specify the certificate key file
      config.vcenter.wsdl = '${webuiPkgs.webCore}/webroot/js/vim.wsdl';
      config.discoveryService = {};
      config.discoveryService.server_port = '5998';
      config.discoveryService.enable = true;
      config.jobServer = {};
      config.jobServer.server_ip = '127.0.0.1';
      config.jobServer.server_port = '3000';
      config.files = {};
      config.files.download_path = '/tmp';
      config.cassandra = {};
      config.cassandra.server_ips = ['127.0.0.1'];
      config.cassandra.server_port = '9042';
      config.cassandra.enable_edit = false;
      config.kue = {};
      config.kue.ui_port = '3002'
      config.webui_addresses = ['0.0.0.0'];
      config.insecure_access = false;
      config.http_port = '8080';
      config.https_port = '8143';
      config.require_auth = false;
      config.node_worker_count = 1;
      config.maxActiveJobs = 10;
      config.redisDBIndex = 3;
      config.redis_server_port = '6379';
      config.redis_server_ip = '127.0.0.1';
      config.redis_dump_file = '/var/lib/redis/dump-webui.rdb';
      config.redis_password = "";
      config.logo_file = '${webuiPkgs.webCore}/webroot/img/opencontrail-logo.png';
      config.favicon_file = '${webuiPkgs.webCore}/webroot/img/opencontrail-favicon.ico';
      config.featurePkg = {};
      config.featurePkg.webController = {};
      config.featurePkg.webController.path = '${webuiPkgs.webController}';
      config.featurePkg.webController.enable = true;
      config.qe = {};
      config.qe.enable_stat_queries = false;
      config.logs = {};
      config.logs.level = 'debug';
      config.getDomainProjectsFromApiServer = false;
      config.network = {};
      config.network.L2_enable = false;
      config.getDomainsFromApiServer = true;
      config.jsonSchemaPath = "${webuiPkgs.webCore}/src/serverroot/configJsonSchemas";
      module.exports = config;
    '';
  };

in {
  options = {
    contrail.webui = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.contrailJobServer = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "contrailDiscovery.service" ];
      serviceConfig.WorkingDirectory = "${webuiPkgs.webCore}";
      preStart = ''
        cp ${web-server} /tmp/contrail-web-core-config.js
      '';
      script = "${pkgs.nodejs-4_x}/bin/node ${webuiPkgs.webCore}/jobServerStart.js";
    };

    systemd.services.contrailWebServer = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "contrailJobServer.service" "contrailAnalyticsApi.service" ];
      serviceConfig.WorkingDirectory = "${webuiPkgs.webCore}";
      script = "${pkgs.nodejs-4_x}/bin/node ${webuiPkgs.webCore}/webServerStart.js";
    };
  };
}
