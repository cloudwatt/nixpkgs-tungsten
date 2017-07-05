This is a WIP project to build Opencontrail components, create
Docker images and define Hydra jobs.

### Install Nix and Clone Required Repositores

```
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

git clone https://github.com/NixOS/nixpkgs-channels.git
git -C nixpkgs-channels checkout 0d4431cfe90b2242723ccb1ccc90714f2f68a609
export NIX_PATH="nixpkgs=$PWD/nixpkgs-channels"

git clone https://github.com/nlewo/nixpkgs-contrail.git
```

### Build the contrail api-server

```
nix-build nixpkgs-contrail/controller.nix -A contrailApi
```
