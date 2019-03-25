{ pkgs
, contrailPkgs
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  machine = { config, ...}: {
    imports = [ ../modules/webui.nix
                ../modules/all-in-one.nix
              ];
    config = rec {
      _module.args = { inherit pkgs contrailPkgs; };

      virtualisation = { memorySize = 4096; diskSize = 2048; cores = 2; };

      contrail.webui.enable = true;

      environment.systemPackages = with pkgs; [
        curl
        gnugrep
        jq
      ];
      environment.variables = {
        CONTRAIL_API_VERSION = contrailPkgs.contrailVersion;
      };

      networking.enableIPv6 = false;

      contrail.allInOne = {
        enable = true;
        vhostInterface = "eth1";
        vhostGateway = "10.0.2.2";
      };
    };
  };
  testScript =
    ''
    # wait for services
    $machine->waitForUnit("contrail-web-server.service");
    $machine->waitForUnit("contrail-job-server.service");

    # check for the login page
    $machine->waitUntilSucceeds("curl -k https://localhost:8143 | grep 'Sign in using your registered account'");

    # try to log in
    $machine->succeed("curl -k -X POST -H \"Content-Type: application/json\" --data '{\"username\": \"admin\", \"password\": \"contrail123\"}' https://localhost:8143/authenticate | jq '.isAuthenticated' | grep true");
  '';
in
  makeTest {
    name = "webui";
    nodes = { inherit machine; };
    testScript = testScript;
  }
