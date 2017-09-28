Nix expressions to build OpenContrail components, run some basic
tests, build Opencontrail preconfigured VMs and deploy a build CI by
using [Hydra](https://nixos.org/hydra/).

### Install [Nix](https://nixos.org/nix/)

```
$ curl https://nixos.org/nix/install | sh
$ . ~/.nix-profile/etc/profile.d/nix.sh
```

### Build OpenContrail Components

```
$ nix-build
```

Or to build specific components
```
$ nix-build -A contrailApi
$ nix-build -A contrailControl # Take a while...
```

`$ nix-env -f default.nix -qaP` to get the list of all components

### Run tests

```
$ nix-build -A test.contrail
```

This launches a vm, installs some Contrail services and runs some basic tests

#### Build an all-in-one VM

```
$ nix-build -A test.contrail.driver && QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/nixos-run-vms

```


### Build a compute node VM

```
$ nix-build -A vms.computeNode
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

