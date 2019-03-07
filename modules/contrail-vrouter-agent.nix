{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let
  # We should try a nixpkgs overlay to avoid this explicit import
  cfg = config.contrail.vrouterAgent;

  vgwOptions = {
    options = {
      projectName = mkOption {
        type = types.str;
        default = "service";
      };
      networkName = mkOption {
        type = types.str;
      };
      networkCIDR = mkOption {
        type = types.str;
      };
      routes = mkOption {
        type = types.str;
      };
      masquerade = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  confFile = import (./configuration + "/R${contrailPkgs.contrailVersion}/vrouter-agent.nix") { inherit pkgs contrailPkgs cfg; };

in {

  options = {

    contrail.vrouterAgent = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      configFile = mkOption {
        type = types.path;
        default = confFile;
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
      debug = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Make debug symbols available for debugging with gdb
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
      autoStart = mkOption {
        type = types.bool;
        default = true;
      };
      logLevel = mkOption {
        type = types.enum [ "SYS_DEBUG" "SYS_INFO" "SYS_WARN" "SYS_ERROR" ];
        default = "SYS_INFO";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ contrailPkgs.vrouterModuleNixos_4_9 ];
    boot.kernelModules = [ "vrouter" ];
    boot.kernelPackages = pkgs.linuxPackages_4_9;

    environment.systemPackages = with contrailPkgs; [
      vrouterPortControl vrouterUtils vrouterNetNs
    ];

    users.users.root.packages = mkIf cfg.debug [ contrailPkgs.vrouterAgent.debug ];

    networking.usePredictableInterfaceNames = false;

    networking.firewall.extraCommands = concatStringsSep "\n"
      (map (gw: optionalString gw.masquerade ''
        iptables -t nat -A POSTROUTING -s ${gw.networkCIDR} -j MASQUERADE
      '') cfg.virtualGateways);

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

    systemd.services = mkMerge ([
      {
        contrail-vrouter-agent = mkMerge [
          {
            after = [ "network.target" ] ++ optional contrailPkgs.isContrail32 "contrail-discovery.service";
            requires = mkIf contrailPkgs.isContrail32 [ "contrail-discovery.service" ];
            # To avoid error
            # contrail-vrouter-agent: controller/src/base/task.cc:293: virtual tbb::task* TaskImpl::execute(): Assertion `0' failed.
            # !!!! ERROR !!!! Task caught fatal exception: locale::facet::_S_create_c_locale name not valid TaskImpl: 0x2418e40
            environment = { "LC_ALL" = "C"; };
            path = [ pkgs.netcat ];
            preStart = ''
              mkdir -p /var/log/contrail/
            '' + optionalString contrailPkgs.isContrail32 ''
              while ! nc -vz ${cfg.discoveryHost} 5998; do
                sleep 2
              done
            '';
            serviceConfig.ExecStart =
              "${contrailPkgs.vrouterAgent}/bin/contrail-vrouter-agent --config_file ${cfg.configFile}";
          }
          (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
        ];
      }
      (mkIf cfg.provisionning {
        provision-vrouter-agent = mkMerge [
          {
            serviceConfig.Type = "oneshot";
            serviceConfig.RemainAfterExit = true;
            after = [ "contrail-vrouter-agent.service" ];
            path = [ pkgs.netcat pkgs.contrailApiCliWithExtra ];
            script = ''
              while ! nc -vz ${cfg.apiHost} 8082; do
                sleep 2
              done
              # creates global-vrouter-config
              contrail-api-cli --ns contrail_api_cli.provision -H ${cfg.apiHost} \
                set-encaps MPLSoGRE MPLSoUDP VXLAN
              # adds virtual-router
              contrail-api-cli --ns contrail_api_cli.provision -H ${cfg.apiHost} \
                add-vrouter --vrouter-ip ${cfg.vhostIP} $HOSTNAME
            '';
          }
          (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
        ];
      })
      {
        configure-vhost-interface = mkMerge [
          {
            serviceConfig.Type = "oneshot";
            serviceConfig.RemainAfterExit = true;
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
          }
          (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
        ];

      }
    ] ++ (map (gw:
      {
        "add-${gw.projectName}-${gw.networkName}-vgw" = mkMerge [
          {
            serviceConfig.Type = "oneshot";
            serviceConfig.RemainAfterExit = true;
            after = [ "contrail-vrouter-agent.service" ];
            requires = [ "contrail-vrouter-agent.service" ];
            path = with pkgs; [ netcat iptables ];
            script = ''
              while ! nc -vz localhost 9091; do
                sleep 2
              done
              ${contrailPkgs.configUtils}/bin/provision_vgw_interface.py --oper create \
                  --interface vgw --subnets ${gw.networkCIDR} --routes ${gw.routes} \
                  --vrf "default-domain:${gw.projectName}:${gw.networkName}:${gw.networkName}"
            '';
          }
          (mkIf cfg.autoStart { wantedBy = [ "multi-user.target" ]; })
        ];
      }
    ) cfg.virtualGateways));

  };

}
