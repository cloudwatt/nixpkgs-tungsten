{ pkgs
, contrailPkgs
# If not set, contrail32 or contrailMaster test scripts are used.
, testScript ? null
}:

with import (pkgs.path + /nixos/lib/testing.nix) { inherit pkgs; system = builtins.currentSystem; };
with pkgs.lib;

let
  machine = { config, ...}: {
    imports = [ ../modules/all-in-one.nix ];

    config = {
      # include pkgs to have access to tools overlay
      _module.args = { inherit pkgs contrailPkgs; };

      virtualisation = { memorySize = 4096; cores = 2; };

      environment.systemPackages = with pkgs; [
        # Used by the test suite
        jq
        contrailApiCliWithExtra
        contrailPkgs.configUtils
      ];

      contrail.allInOne = {
        enable = true;
        vhostInterface = "eth1";
        vhostGateway = "10.0.2.2";
      };
    };
  };

  contrailTestScript = ''
    $machine->waitForUnit("cassandra.service");
    $machine->waitForUnit("rabbitmq.service");
    $machine->waitForUnit("zookeeper.service");
    $machine->waitForUnit("redis.service");

  '' + optionalString contrailPkgs.isContrail32 ''
    $machine->waitForUnit("contrail-discovery.service");
  '' + ''
    $machine->waitForUnit("contrail-api.service");
    $machine->waitForUnit("contrail-svc-monitor.service");
    $machine->waitForUnit("contrail-schema-transformer.service");

    $machine->waitForUnit("contrail-analytics-api.service");
    $machine->waitForUnit("contrail-collector.service");
    $machine->waitForUnit("contrail-control.service");

  '' + optionalString contrailPkgs.isContrail32 ''
    # check services state
    my @services = qw(ApiServer IfmapServer Collector OpServer xmpp-server);
    foreach my $service (@services)
    {
      $machine->waitUntilSucceeds(sprintf("curl -s localhost:5998/services.json | jq -e '.services[] | select(.service_type == \"%s\" and .oper_state == \"up\")'", $service));
    }
  '' + ''

    $machine->succeed("lsmod | grep -q vrouter");
    $machine->waitForUnit("contrail-vrouter-agent.service");

    $machine->waitUntilSucceeds("curl http://localhost:8083/Snh_ShowBgpNeighborSummaryReq | grep machine | grep -q Established");
    $machine->waitUntilSucceeds("curl -s localhost:8081/analytics/uves/vrouter/*?cfilt=NodeStatus:process_status | jq '.value | map(select(.value.NodeStatus.process_status[0].state == \"Functional\")) | length' | grep -q 1");

    $machine->succeed("contrail-api-cli --ns contrail_api_cli.provision add-vn --project-fqname default-domain:default-project --subnet 20.1.1.0/24 vn1");
    $machine->succeed("netns-daemon-start -n default-domain:default-project:vn1 vm1");
    $machine->succeed("netns-daemon-start -n default-domain:default-project:vn1 vm2");

    $machine->succeed("ip netns exec ns-vm1 ip a | grep -q 20.1.1.252");
    $machine->succeed("ip netns exec ns-vm1 ping -c1 20.1.1.251");
  '';

in
  makeTest {
    name = "all-in-one";
    nodes = { inherit machine; };
    testScript = if testScript != null then testScript else contrailTestScript;
  }
