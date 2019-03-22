# nixpkgs-contrail

**nixpkgs-contrail** provides tools and workflows that make developing and testing [OpenContrail](http://www.opencontrail.org/) _easy_, _efficient_, and _convenient_. 

## Table of Contents

* [Introduction](#Introduction)
* [Installing Nix](#installing-nix)
    * [Configuring Nix](#configuring-nix)
* [Usage Scenarios](#usage-scenarios)
    * [Running OpenContrail in a VM](#running-opencontrail-in-a-vm)
    * [Building OpenContrail from sources](#building-opencontrail-from-sources)
    * [Working on a single component](#working-on-a-single-component)
    * [Start a Contrail VM with an existing configuration database](#running-a-vm-with-an-existing-configuration-database)
    * [Installing OpenContrail related tools](#installing-opencontrail-related-tools)
* [Testing](#testing)
* [How to contribute](#how-to-contribute) <!-- hydra does PR testing, your test needs to pass.. -->
* [Miscellaneous](#Miscellaneous)
    * [Installing Nix shell completion](#installing-nix-shell-completion)
    * [Contributing](#contributing)

## Introduction

OpenContrail is a widely adopted and powerful Open Source SDN solution. OpenContrail is 
powerful but also complex and as such not trivial to build and test. 

The goal of **nixpkgs-contrail** is to improve these workflows and make it much 
easier to develop features and test them in virtual environments.

The only prerequisite and hard dependency of **nixpkgs-contrail** is 
[Nix](https://nixos.org/nix). Nix provides all relevant features from provisioning 
dependencies to the instrumentation of the [QEMU](https://www.qemu.org) based tests.

_The rest of this README walks you through the required setup steps and presents the most
typical usecase scenarios of **nixpkgs-contrail**_.

## Installing Nix

The only prerequisite to building OpenContrail is is a working Nix installation.
If you aren't already using Nix you can you install Nix using the following
command:

```
$ curl https://nixos.org/nix/install | sh
```

For more detailed information about Nix please refer to [https://nixos.org/nix](https://nixos.org/nix/).

### Configuring Nix

While not strictly necessary to build OpenContrail, below are some suggested 
configurations for making your workflow more convenient.

#### Using the OpenContrail Nix channel

The [Hydra CI](http://84.39.63.212/) server provides binaries of this project and its
dependencies through a [nix channel](https://nixos.org/nix/manual/#sec-channels). If you configure your
local nix setup to use this channel you won't have to build binaries that have previously been generated
by the CI server. Follow the instructions below to make use of the CI server:

**1. Adding the contrail channel**

```
$ nix-channel --add http://84.39.63.212/jobset/opencontrail/trunk/channel/latest contrail
$ nix-channel --update
```

You should now be able to find contrail nix expressions using the the [query](https://nixos.org/nix/manual/#operation-query)
command of `nix-env`:

```
$ nix-env -qa '.*contrail.*'
```

**2. Updating ~/.config/nix/nix.conf**

While the instructions of the previous step made the nix expressions (~= the build instructions) for
OpenContrail available, the following configuration changes are necessary to tell nix where
to obtain the binaries that these expressions create. Edit (or create if it doesn't already exist)
`~/.config/nix/nix.conf` and add the following contents:

```
# ~/.config/nix/nix.conf
substituters = https://cache.nixos.org http://84.39.63.212
trusted-substituters = http://84.39.63.212
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.opencontrail.org:u/UFsj0N3c/Ycell/q81MiPRo0Zz6ZlVqu3wB2SY340=
```

## Usage Scenarios

**nixpkgs-contrail** is _not_ meant to be a replacement of the upstream OpenContrail distribution. Instead it
provides several use-cases that make working with OpenContrail very convenient. Below is a description of the most
prominent use-cases.

### Running OpenContrail in a VM

Starting a VM with one of the supported versions of OpenContrail and all currently available components is done as follows:

```
$ nix-build -A contrail32.test.allInOne # builds the VM image
$ ./result/bin/nixos-run-vms            # starts the VM in qemu
```

The example above starts a VM with OpenContrail 3.2, the same will
also work with `contrail41` or `contrail50`. It is also possible to 
start the VM with ssh access enabled:

```
$ nix-build -A contrail32.test.allInOne.driver
$ QEMU_NET_OPTS="hostfwd=tcp::2222-:22" result/bin/nixos-run-vms
$ ssh -p 2222 root@localhost
Password: <ENTER>
```

### Building OpenContrail from sources

All OpenContrail components packaged in **nixpkgs-contrail** can be built using [nix-build](https://nixos.org/nix/manual/#sec-nix-build) by 
specifying the attribute path of the component. All components are grouped by the OpenContrail version, which is currently one of the following:

- `contrail32`
- `contrail41`
- `contrail50`

A query command like the one below can be used to find out which components belong to a given OpenContrail 
version:

```
$ nix-env -f default.nix -qaP -A contrail50
contrail32.analyticsApi             contrail-analytics-api-3.2
contrail32.apiServer                contrail-api-server-3.2
contrail32.collector                contrail-collector-3.2
contrail32.configUtils              contrail-config-utils-3.2
...
```

You can then build any of those individually by passing the attribute path (the first column
in the example output above) to `nix-build`:

```
$ nix-build -A contrail32.configUtils
```

### Working on a single component

The [`nix-shell`](https://nixos.org/nix/manual/#sec-nix-shell) command can be used to provide
a shell in which all dependencies of a specified package are available. The following command
creates an environment for working on the `control` component:

```
$ nix-shell -A contrail32.control
```

This command will spawn an interactive shell in which the sources and all build-time dependencies
of `control` have been fetched by nix. In order to start working on the sources some shell scripts
have to be used to obtain the sources

After `nix-shell` has fetched all packages required to build `contrail32.control`, you will be
placed in an interactive shell. In order to start working on the `control` package you need
to use some of the shell functions provided by the `nix-shell` environment:

```
$ unpackPhase && cd $sourceRoot
unpacking source archive /nix/store/9jswqjmq6q4ijrmac5qbw2z5b63cl1x0-contrail-workspace
source root is contrail-workspace
$ scons contrail-control
```				 

This approach also makes it easy to test patches or upstream to single components locally.

### Running a VM with an existing configuration database

Instead of just running a generic setup it can be desirable to replicate an existing configuration.
This can be achieved by providing a cassandra database dump to the `allInOne` VM.

The `databaseLoader` tool provides this functionality. In order to use it, it
needs to be built first:

```
$ nix-build -A contrail32.databaseLoader
$ ./result
```

Running the program for the first time it will produce some information
with details on the files that need to be created, how to create them,
and where they need to be placed. 

Execute `./result` again after following the given instructions.

### Installing OpenContrail related tools

**nixpgs-contrail** also provides various utilities on top of the standard OpenContrail software components:

- [contrailIntrospectCli](https://github.com/nlewo/contrail-introspect-cli)
- [contrailApiCliWithExtra](https://github.com/eonpatapon/contrail-api-cli)
- [contrailGremlin](https://github.com/eonpatapon/contrail-gremlin)
- gremlinChecks
- [gremlinConsole](https://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/)
- [gremlinServer](https://tinkerpop.apache.org/)
- [gremlinFsck](https://github.com/eonpatapon/contrail-gremlin/tree/master/gremlin-fsck)

All tools can be installed using `nix-env`:

```
$ nix-env -iA contrailIntrospectCli -f default.nix
```

## Testing

The tests are implemented using the [NixOS testing framework](https://nixos.org/nixos/manual/index.html#sec-nixos-tests). 
Essentially the tests will boot a server inside QEMU, deploy and start OpenContrail and execute a sequence of commands and
assertions to test if the setup is working as expected. The following test cases are available:

- [`allInOne`](./test/all-in-one.nix): Starts OpenContrail services, creates networks and ports and performs a simple traffic test.
- [`tcpFlow`](./test/flows.nix): Generates TCP traffic and checks if the traffic is behaving according to the configured security groups.
- [`udpFlow`](./test/flows.nix): Generates UDP traffic and checks if the traffic is behaving according to the configured security groups.

All of the tests above can be executed as follows for any of the supported OpenContrail versions:

```
$ nix-build -A contrail32.test.allInOne
$ nix-build -A contrail41.test.udpFlow
$ nix-build -A contrail50.test.tcpFlow
```

Apart from generating a lot of output on the terminal, each test execution will also
ceate a `result` output link containing a `log.html` file which contains a pretty-printed 
overview of the test.

Please refer to the [NixOS manual](https://nixos.org/nixos/manual/index.html#sec-nixos-tests) for more details.

## Miscellaneous

### Installing Nix shell completion

With nix completion support for your shell you can get `<TAB>` triggered completions
for nix commands and attributes of nix files like those contained in this project.

- **bash**: Nix Completion for Bash is provided by [nix-bash-completions](https://github.com/hedning/nix-bash-completions). 
For installation and usage instructions please refer to the project website.
- **zsh**: Nix Completion for ZSH is provided by [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions).
For installation and usage instructions please refer to the projet website.

### Contributing

Contributions to **nixpkgs-contrail** through PRs are always welcome. All PRs will be automatically tested by the
[Hydra CI](http://84.39.63.212/) server. For more information on the setup of the hydra instance please refer
to the [CI documentation](./ci/README.md).
