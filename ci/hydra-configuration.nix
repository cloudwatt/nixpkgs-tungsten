# This configuration has been used to deploy hydra
# Use it with nixops or paste it to /etc/nixos/configuration.nix

{pkgs, ...}:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/nova-config.nix> ];

  # Be careful since this has to be commented for the first
  # boot... The store has to be manually first copyied to this
  # partition.
  fileSystems."/nix/store" = {
    device = "/dev/vdb";
    fsType = "ext3";
  };

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

  services.haveged.enable = true;

  nix = {
    distributedBuilds = true;
    extraOptions = ''
      auto-optimise-store = true
    '';
    buildMachines = [
      {
        hostName = "localhost";
        systems = [ "x86_64-linux" "builtin" ];
        maxJobs = 8;
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
      }
    ];
  };
}
