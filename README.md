Nix expressions to build OpenContrail components, run some basic
tests, build OpenContrail preconfigured VMs and deploy a build CI by
using [Hydra](https://nixos.org/hydra/).


### Install [Nix](https://nixos.org/nix/)

```
$ curl https://nixos.org/nix/install | sh
$ . ~/.nix-profile/etc/profile.d/nix.sh
```


### Subscribe to the OpenContrail Nix channel

This [Hydra CI](http://84.39.63.212/) builds OpenContrail expressions
and creates a channel (a kind of packages repository) that can be used
to get precompiled OpenContrail sotfwares.


```
$ nix-channel --add http://84.39.63.212/jobset/opencontrail/trunk/channel/latest contrail
$ nix-channel --update
```

We can easily install the `contrail-api` for instance:
```
$ nix-env -iA contrail.contrail32-api
$ contrail-api -h
```

Note: if we don't subscribe to the channel, all OpenContrail Nix
      expressions will be locally built.


### Build OpenContrail Components

To build all OpenContrail components
```
$ nix-build -A contrail32
```

Or to build specific ones
```
$ nix-build -A contrail32.api
$ nix-build -A contrail32.control
```

`$ nix-env -f default.nix -qaP -A contrail32` to get the list of all attributes


### Run basic tests

```
$ nix-build -A contrail32.test.allInOne
```

The `allInOne` test creates a virtual machine and deploys several
OpenContrail components. It then checks services provisioning
(discovery, bgp peering,...), associates ports to `net namespaces` and
validates ping is working.


To run all tests
```
$ nix-build -A contrail32.test
```


#### Build and run an all-in-one VM

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


### Using `nix-shell` to locally compile `contrail-control`

```
$ nix-shell -A contrail32.control # Can download lot of things
```

`nix-shell` has download all build requires of `contrail-control` and
prepare a build environment. We can then get the contrail workspace,
and run `scons` to start the `contrail-control` compilation

```
$ unpackPhase && cd $sourceRoot
unpacking source archive /nix/store/9jswqjmq6q4ijrmac5qbw2z5b63cl1x0-contrail-workspace
source root is contrail-workspace
$ scons contrail-control
```				 
