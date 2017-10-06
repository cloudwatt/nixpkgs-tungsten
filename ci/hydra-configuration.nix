# This configuration has been used to deploy hydra
# Use it with nixops or paste it to /etc/nixos/configuration.nix

{pkgs, ...}:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/nova-config.nix> ];

  networking.firewall = {
    allowedTCPPorts = [ 22 80 3000 ];
    # because hydra user is not allowed to bind port 80
    extraCommands = ''
      iptables -t nat -A PREROUTING -p TCP --dport 80 -j REDIRECT --to-port 3000
      '';
  };

  # Switch to kernel 4.4 because nested virtualisation is broken
  # with kernel 4.9. See https://github.com/NixOS/nixpkgs/issues/27930
  boot.kernelPackages = pkgs.linuxPackages_4_4;

  services.hydra = {
    enable = true;
    hydraURL = "http://example.com";
    notificationSender = "hydra@example.com";
    extraConfig = ''
      max_output_size = 4294967296
      binary_cache_secret_key_file = /etc/nix/hydra-1/secret
    '';
  };

  nix = {
    distributedBuilds = true;
    extraOptions = ''
      auto-optimise-store = true
    '';
        buildMachines = [
    {
          hostName = "localhost";
          systems = [ "x86_64-linux" ];
          maxJobs = 8;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel"];
        }
    ];
  };
}
