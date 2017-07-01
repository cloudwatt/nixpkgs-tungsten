Enable the hydra services in configuration.nix, and create an admin account by using the hydra account
```
$ su - hydra
$ hydra-init
$ hydra-create-user admin --role admin --password admin
```

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
