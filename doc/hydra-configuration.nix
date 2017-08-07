# This configuration has been used to deploy hydra and the docker
# registry.
# Use it with nixops or paste it to /etc/nixos/configuration.nix

{pkgs, ...}:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/nova-config.nix> ];

  networking.firewall.allowedTCPPorts = [ 22 3000 5000 6000 ];

  services.dockerRegistry.enable = true;

  virtualisation.docker.enable = true;

  # Switch to kernel 4.4 because nested virtualisation is broken
  # with kernel 4.9. See https://github.com/NixOS/nixpkgs/issues/27930
  boot.kernelPackages = pkgs.linuxPackages_4_4;

  services.hydra.enable = true;
  services.hydra.hydraURL = "http://example.com";
  services.hydra.notificationSender = "hydra@example.com";
  services.hydra.extraConfig = ''
    max_output_size = 4294967296
    binary_cache_secret_key_file = /etc/nix/hydra-1/secret
  '';
  # services.hydra.debugServer = true;

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
