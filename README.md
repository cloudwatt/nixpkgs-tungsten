Build OpenContrail components, Docker images, Debian packages and
define [Hydra](https://nixos.org/hydra/) jobs.

### Install [Nix](https://nixos.org/nix/)

```
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
```

### Build OpenContrail Components

```
nix-build -A contrailApi
nix-build -A contrailControl # Take a while...
```

`nix-env -f default.nix -qaP` to get the list of all components

### Build Docker Images

```
nix-build -A images.dockerContrailApi
docker load < result
```

`nix-env -f default.nix -qaP -A images` to get the list of all images

### Build Debian Packages

```
nix-build -A debian.contrailVrouter
```
