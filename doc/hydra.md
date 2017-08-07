### Hydra initialisation

Enable the hydra services in `configuration.nix`, and create an admin account by using the hydra account
```
$ su - hydra
$ hydra-init
$ hydra-create-user admin --role admin --password admin
```

### Create a first jobset

Unfortunately, we have to manually create this jobset in hydra...

The Hydra jobset configuration is:
```
State: 	Enabled
Description: 	Contrail
Nix expression: 	jobset.nix in input ciSrc
Check interval: 	60
Scheduling shares: 	100 (100.00% out of 100 shares)
Enable email notification: 	No
Email override: 	
Number of evaluations to keep: 	5

Inputs
Input name	Type	Values
ciSrc 	Git checkout 	https://github.com/nlewo/nixpkgs-contrail ci
nixpkgs 	Git checkout 	https://github.com/NixOS/nixpkgs-channels 0d4431cfe90b2242723ccb1ccc90714f2f68a609
```

### Hydra Channel Configuration

To use channels, you have to sign them

#### On the hydra machine
```
install -d -m 551 /etc/nix/hydra-1
nix-store --generate-binary-cache-key hydra /etc/nix/hydra-1/secret /etc/nix/hydra-1/public
chown -R hydra:hydra /etc/nix/hydra-1/
chmod 440 /etc/nix/hydra-1/secret 
chmod 444 /etc/nix/hydra-1/public 

```

This could be added to the `Nixos` configuration file as done [here](https://github.com/peti/hydra-tutorial/blob/b2703510026caf6fd676ad3bb5aec84d5958d190/hydra-master.nix#L63).

#### On the client side

You have to set the public key of your hydra instance in your `nix.conf` file:

```
trusted-binary-caches = http://your-hydra:3000
binary-cache-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra:Rt2X5wXmBCq+YnUlW7a/xRxYHBwAVuNkE6MWY8GvCn4=
```

You can then get binary packages built by hydra:
```
  nix-build -A contrailControl  --option binary-caches http://your-hydra:3000/
```
