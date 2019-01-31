# This configuration has been used to deploy hydra
# Use it with nixops or paste it to /etc/nixos/configuration.nix

{ pkgs, config, ... }:

{

  imports = [
    <nixpkgs/nixos/modules/virtualisation/nova-config.nix>
  ];

  time.timeZone = "Europe/Paris";

  networking.firewall.allowedTCPPorts = [ 22 ];

  # Switch to kernel 4.4 because nested virtualisation is broken
  # with kernel 4.9. See https://github.com/NixOS/nixpkgs/issues/27930
  boot.kernelPackages = pkgs.linuxPackages_4_4;

  services.haveged.enable = true;

  environment.systemPackages = with pkgs; [
    vim htop tmux
  ];

}
