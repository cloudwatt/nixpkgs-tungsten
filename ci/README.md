This describes how to bootstrap the [Hydra
CI](https://nixos.org/hydra/) which builds `nixpkgs-contrail`
expressions. It also runs some tests and exposes a [binary
cache](https://nixos.org/nix/manual/#idm140737318588960).


### Hydra provisionning

A [configuration file](./hydra-configuration.nix) is provided to start
required services on a NixOS machine.

Note1 we use a NixOS 17.03 since nested virtualisation doesn't work
well with kernel >= 4.9.

Note2 if postgresql fails to start, try to `chmod 777 /tmp`.


### Hydra initialisation

Hydra has been initalized by the NixOS module and we just have to
create an admin account by using the hydra account
```
$ hydra-create-user admin --role admin --password admin
```

### Create a project and a jobset

The script `create-project.sh` creates a project and a jobset to build
this `nixpkgs-contrail` repository.
```
URL=YOUR-HYDRA USERNAME=admin PASSWORD=admin bash doc/create-project.sh
```


### Hydra Channel Configuration

To create a binary cache and use channels, we have to create a key pair.

```
hydra$ install -d -m 551 /etc/nix/hydra-1
hydra$ nix-store --generate-binary-cache-key cache.opencontrail.org /etc/nix/hydra-1/secret /etc/nix/hydra-1/public
hydra$ chown -R hydra:hydra /etc/nix/hydra-1/
hydra$ chmod 440 /etc/nix/hydra-1/secret 
hydra$ chmod 444 /etc/nix/hydra-1/public 
```

Non NixOS users can then use this cache by just setting a CLI option
```
  nix-build -A contrailControl  --option binary-caches http://your-hydra:3000/
```

NixOS users have to trust this key by setting the following options in the `nix.conf`:
```
trusted-binary-caches = http://your-hydra:3000
binary-cache-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.opencontrail.org:OWF7nfkyJEPX4jYvOrcuelFUH4njVRJ6SDM6+xlFUOQ=
```
