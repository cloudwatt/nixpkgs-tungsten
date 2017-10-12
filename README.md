Nix expressions to build OpenContrail components, run some basic
tests, build OpenContrail preconfigured VMs and deploy a build CI by
using [Hydra](https://nixos.org/hydra/).


### Install [Nix](https://nixos.org/nix/)

```
$ curl https://nixos.org/nix/install | sh
$ . ~/.nix-profile/etc/profile.d/nix.sh
```


### Build OpenContrail Components

```
$ nix-build -A contrail32 # Take a while...
```

Or to build specific components
```
$ nix-build -A contrail32.api
$ nix-build -A contrail32.control # Take a while...
```

`$ nix-env -f default.nix -qaP -A contrail32` to get the list of all attributes


### Run tests

```
$ nix-build -A contrail32.test.allInOne
```

This launches a vm, installs some Contrail services and runs some basic tests


#### Build an all-in-one VM

```
$ nix-build -A contrail32.test.allInOne && QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/nixos-run-vms

```


### Build a compute node VM

```
$ nix-build -A contrail32.vms.computeNode
```
builds a script to run a compute node with QEMU.

Once built, the VM can be run
```
$ QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/nixos-run-vms
```

and reached with

```
$ ssh -p 2222 root@localhost
Password: root
```

A default configuration file is generated. By default, the agent
tryies to contact the controller, discovery and collector by using
the IP `172.16.42.42` which could be overriden at build time in
`tools/build-vms.nix`.


### Install and run precompiled `contrail-api-server`

```
$ nix-channel --add http://84.39.63.212/jobset/opencontrail/trunk/channel/latest contrail
$ nix-channel --update
$ nix-env -iA contrail.contrail32-api
$ contrail-api -h
```

We first subscribe to a Nix channel in order to be able to install
precompiled components in the current user environment.


