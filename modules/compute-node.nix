{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  # We should try a nixpkgs overlay to avoid this explicit import
  cfg = config.contrail.vrouterAgent;

  vgwOptions = {
    options = {
      networkName = mkOption {
        type = types.str;
      };
      networkCIDR = mkOption {
        type = types.str;
      };
      routes = mkOption {
        type = types.str;
      };
    };
  };

  agentConf = pkgs.writeTextFile {
    name = "contrail-agent.conf";
    text = ''
      [DEFAULT]
      ble_flow_collection = 1
      log_file = /var/log/contrail/vrouter.log
      log_level = SYS_DEBUG
      log_local = 1

      [DISCOVERY]
      port = 5998
      server = ${cfg.discoveryHost}

      [VIRTUAL-HOST-INTERFACE]
      name = vhost0
      ip = ${cfg.vhostIP}/24
      gateway = ${cfg.vhostGateway}
      physical_interface = ${cfg.vhostInterface}

      [FLOWS]
      max_vm_flows = 20

      [METADATA]
      metadata_proxy_secret = t96a4skwwl63ddk6

      [TASK]
      tbb_keepawake_timeout = 25

      [SERVICE-INSTANCE]
      netns_command = ${contrailPkgs.vrouterNetNs}/bin/opencontrail-vrouter-netns
    '';
  };

in {

  options = {

    contrail.vrouterAgent = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configurationFilepath = mkOption {
        type = types.str;
        default = "";
        description = ''
          To specify a alternative configuration filepath.
          The generated configuration file is no longer used.
        '';
      };
      provisionning = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If enabled, the contrail-vrouter unit wait for the
          contrailApi and register itself as active vrouter.
          Note this currently only works if the Vrouter is collocated
          with the Contrail API.
        '';
      };
      discoveryHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      apiHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      vhostInterface = mkOption {
        type = types.str;
        default = "eth0";
        description = "Physical interface name to which virtual host interface maps to";
      };
      vhostIP = mkOption {
        type = types.str;
        default = "192.168.1.1";
        description = "IP address of the virtual host attached interface";
      };
      vhostGateway = mkOption {
        type = types.str;
        default = "192.168.1.1";
        description = "Gateway of the virtual host attached interface";
      };
      virtualGateways = mkOption {
        type = with types; listOf (submodule vgwOptions);
        default = [];
        description = "List of virtual gateway to create";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ (contrailPkgs.lib.buildVrouter pkgs.linuxPackages_4_9.kernel.dev) ];
    boot.kernelModules = [ "vrouter" ];
    boot.kernelPackages = pkgs.linuxPackages_4_9;

    environment.systemPackages = with contrailPkgs; [
      vrouterPortControl vrouterUtils vrouterNetNs
    ];

    networking.usePredictableInterfaceNames = false;

    # This is to prevent the netns-daemon-start to update resolv.conf
    # (since it is using dhclient).
    environment.etc.dhclient-enter-hooks = {
      text = ''
        #!/bin/sh
        make_resolv_conf() {
        echo "doing nothing to resolv.conf"
        }'';
      mode = "0555";
    };

    systemd.services = {

      contrail-vrouter-agent = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        # To avoid error
        # contrail-vrouter-agent: controller/src/base/task.cc:293: virtual tbb::task* TaskImpl::execute(): Assertion `0' failed.
        # !!!! ERROR !!!! Task caught fatal exception: locale::facet::_S_create_c_locale name not valid TaskImpl: 0x2418e40
        environment = { "LC_ALL" = "C"; };
        path = [ pkgs.netcat pkgs.contrailApiCliWithExtra ];
        preStart = ''
          mkdir -p /var/log/contrail/
          while ! nc -vz ${cfg.discoveryHost} 5998; do
            sleep 2
          done
        '';
        script = if cfg.configurationFilepath == ""
          then "${contrailPkgs.vrouterAgent}/bin/contrail-vrouter-agent --config_file ${agentConf}"
          else "${contrailPkgs.vrouterAgent}/bin/contrail-vrouter-agent --config_file ${cfg.configurationFilepath}";
        postStart = mkIf cfg.provisionning ''
          while ! nc -vz ${cfg.apiHost} 8082; do
            sleep 2
          done
          # creates global-vrouter-config
          contrail-api-cli --ns contrail_api_cli.provision -H ${cfg.apiHost} set-encaps MPLSoGRE MPLSoUDP VXLAN
          # adds virtual-router
          contrail-api-cli --ns contrail_api_cli.provision -H ${cfg.apiHost} add-vrouter --vrouter-ip ${cfg.vhostIP} $HOSTNAME
        '';
      };

      configure-vhost-interface = {
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        before = [ "contrail-vrouter-agent.service" ];
        path = [ pkgs.iproute contrailPkgs.vrouterUtils ];
        script = ''
          set -x
          sleep 2
          CONTRAIL_INTERFACE=${cfg.vhostInterface}
          vif --create vhost0 --mac $(cat /sys/class/net/$CONTRAIL_INTERFACE/address)
          vif --add $CONTRAIL_INTERFACE --mac $(cat /sys/class/net/$CONTRAIL_INTERFACE/address) \
            --vrf 0 --vhost-phys --type physical
          vif --add vhost0 --mac $(cat /sys/class/net/$CONTRAIL_INTERFACE/address) \
            --vrf 0 --xconnect $CONTRAIL_INTERFACE --type vhost
          ip link set vhost0 up
          # Warning, this doesn't work if a default route is installed
          # on the CONTRAIL_INTERFACE.
          ROUTE=$(ip r | grep $CONTRAIL_INTERFACE | sed 's/\(.*\) dev.*/\1/')
          IP=$(ip a show $CONTRAIL_INTERFACE | grep "inet "| sed 's/.*inet \(.*\) scope.*/\1/')
          ip a del $IP dev $CONTRAIL_INTERFACE
          ip a add $IP dev vhost0
          ip r del $ROUTE dev $CONTRAIL_INTERFACE || true
          ip r add $ROUTE dev vhost0 || true
          sleep 1
        '';
      };
    } // listToAttrs (map (gw:
      nameValuePair "add-${gw.networkName}-vgw"
      {
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "contrail-vrouter-agent.service" ];
        path = [ pkgs.netcat ];
        script = ''
          while ! nc -vz localhost 9091; do
            sleep 2
          done
          ${contrailPkgs.configUtils}/bin/provision_vgw_interface.py --oper create \
              --interface vgw --subnets ${gw.networkCIDR} --routes ${gw.routes} \
              --vrf "default-domain:service:${gw.networkName}:${gw.networkName}"
        '';
      }) cfg.virtualGateways);

    };

}
