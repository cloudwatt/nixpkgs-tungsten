# nixpkgs-tungsten

**nixpkgs-tungsten** provides tools and workflows that make developing and testing [OpenContrail](http://www.opencontrail.org/) _easy_, _efficient_, and _convenient_.

## Table Of Contents

* [Introduction](#introduction)
* [Using ./please for easy nixpkgs-tungsten interaction](#using-please-for-easy-nixpkgs-tungsten-interaction)
* [Manual Configuration](#manual-configuration)
  * [Installing Nix](#installing-nix)
  * [Configuring the Nix channel](#configuring-the-nix-channel)
  * [Configuring the binary cache](#configuring-the-binary-cache)
* [Additional Usage Scenarios](#additional-usage-scenarios)
   * [Running a VM with an existing configuration database](#running-a-vm-with-an-existing-configuration-database)
   * [Installing OpenContrail related tools](#installing-opencontrail-related-tools)
* [Miscellaneous](#miscellaneous)
   * [Contributing](#contributing)

## Introduction

OpenContrail is a widely adopted and powerful Open Source SDN solution. OpenContrail is
powerful but also complex and as such not trivial to build and test.

The goal of **nixpkgs-tungsten** is to improve these workflows and make it much
easier to develop features and test them in virtual environments.

The only prerequisite and hard dependency of **nixpkgs-tungsten** is
[Nix](https://nixos.org/nix). Nix provides all relevant features from provisioning
dependencies to the instrumentation of the [QEMU](https://www.qemu.org) based tests.

Included with this project is `please`, a thin convenience layer on top of Nix which makes getting started
with **nixpkgs-tungsten** much easier. Note that all `please` commands will always output the Nix command
that is actually being executed. Experienced Nix users might want to use Nix commands directly for
more advanced or specific usages.

## Using `./please` for easy nixpkgs-tungsten interaction

```
$ ./please
Usage: please <command> [args]

 build [artifact]     -- build an artifact
 completions          -- output completion script
 doctor               -- perform sanity checks
 init                 -- configure initial setup
 install [artifact]   -- install an artifact
 list                 -- list artifacts and tests
 run-test [test]      -- run a test
 run-vm [test]        -- run an interactive vm of a test
 shell [artifact]     -- enter a dev shell for an artifact
 uninstall [artifact] -- uninstall a previously installed artifact

In order to enable context-sensitive completions (bash only!) run:

  $ source <(./please completions)

You should add this to your init scripts.
```

The `./please` script provides a convenience layer for performing the most typical actions such as building or installing packages provided through **nixpkgs-tungsten**.
Experienced Nix users are more likely to use Nix tooling directly, for everyone
else this provides a good way to get started.

### `please init`

Installing and configuring Nix can be performed automatically using `./please init`.
The init command will:

1. Install Nix if it isn't installed already
1. Configure the contrail nix channel
1. Configure the contrail binary cache

Note that the binary cache will not be configured if there is a
`~/.config/nix/nix.conf` file already. In this case you will have to make the
changes to your configuration by hand as described below.

### `please doctor`

After the completing the initialization you can run `./please doctor` to verify that
everything was installed and configured successfully.

```
$ ./please doctor
[please]: Running sanity checks:

- Nix installed :  OK
- contrail channel: OK
- contrail cache: OK

All tests passed.
```

If there are any errors you may
want to refer to the description of the manual steps provided below.

### `please completions`

If you are using _bash_ , you are advised to make use of the shell completions:

```
$ source <(please completions)
```

The context sensitive completions make it easier to discover packages provided by **nixpkgs-tungsten**.

### `please list`

In order to get an overview of the packages provided by **nixpkgs-tungsten** you can
use the `list` command:

```
$ ./please list
contrailApiCliWithExtra
contrailGremlin
contrailIntrospectCli
gremlinChecks
gremlinConsole
gremlinFsck
gremlinServer
contrail32.analyticsApi
[...]
```

### `please build`

In order to build any **nixpkgs-tungsten** package you can use `./please build`:

```
$ ./please build contrail50.apiServer
[please]: Running "nix-build default.nix -A contrail50.apiServer"

/nix/store/9v6bv14g19zwbix1d2xz7rkvw2palh46-contrail-api-server-5.0

[please]: Your build result is symlinked in ./resul
```

**Note**: When no changes have been made to your working copy a `build`
command is likely to make use of the _binary cache_ and not actually build
anything locally at all.



### `please install`

In order to install any **nixpkgs-tungsten** package you can use `./please install`:

```
$ ./please install gremlinConsole
[please]: Running "nix-env -f default.nix -iA gremlinConsole"

installing 'gremlin-console-3.3.6'
these paths will be fetched (29.04 MiB download, 210.92 MiB unpacked):
  /nix/store/8xxcgy2dqnlm6zvlncrva30ilyz47vrq-openjdk-8u192b26
  /nix/store/nr75pz171d2hf4liszqv70sr0k4k2cl0-gremlin-console-3.3.6

[...]

building '/nix/store/vi8i0syckhm55alj2v35p7rz2vs9ha30-user-environment.drv'...
created 6366 symlinks in user environment
```

### `please uninstall`

In order to uninstall any previously installed **nixpkgs-tungsten** package you can use `./please uninstall`:

```
$ ./please uninstall gremlinConsole
[please]: Running "nix-env -e gremlin-console-3.3.6"

uninstalling 'gremlin-console-3.3.6
```

**Note**: While the completions provided via `please completions` are generally context-sensitive,
the completions provided for `uninstall` are for _all_ available packages and not only the ones currently
installed. Uninstalling a package that is not currently installed will not yield an error.

### `please run-vm`

The tests provided by **nixpkgs-tungsten** are all executed in virtual machines.
Instead of only executing the tests and shutting down the virtual machine again the
machines can also be run in an interactive mode using the `run-vm` command:

```
$ ./please run-vm contrail50.test.allInOne
```

Once the VM is up and running you can access the machine via ssh on port 2222 of
your localhost:

```
$ ssh -p 2222 root@localhost
Password: <ENTER>
```

Furthermore ports `8080` and `8143` are both also forwarded. If you are running a VM
where the webui is enabled you can access it via https://localhost:8143

### `please shell`

If you want to work on a single package provided by **nixpkgs-tungsten**, make
changes and try to build it you can do so using the `shell` command:

```
$ ./please shell contrail50.control

[please]: Running "nix-shell default.nix -A contrail50.control"
these paths will be fetched (89.48 MiB download, 588.27 MiB unpacked):
  /nix/store/1iih7pgc7krhis13zaq8ajdcb2hd10d9-bzip2-1.0.6.0.1-bin
  /nix/store/1mfd0aahjy42pr1kkcns2qhkw4idf39x-hook
  /nix/store/20nzjbfa0j2r4jc92x7nr33yclsk2wg1-hook
  /nix/store/26lgqf0ja6rx8dnz972a3f56vfxmmmv5-xz-5.2.4-bin

  [...]

[nix-shell:~/]$
```

This will drop you into a terminal where all build-time dependencies (tools and
libraries) required by the package you specified are available. In order to get
the sources of the package you are interested in you have to evaluate the
_unpackPhase_:

```
$ unpackPhase && cd $sourceRoot
unpacking source archive /nix/store/alac0s10.../contrail-workspace
source root is contrail-workspace
```

Now you can build the respective package. In this case `contrail-control` which is built using `scons`:

```
$ scons contrail-control
```

#### Build cache

Building C++ dependencies can be quite time consuming. Instead of running a
shell for `contrail50.control` you can use the `contrail50.dev.control` attribute
which will add the build cache for the current commit in the build environment.

In this case the build will be much faster because `.o` files from the cache
will be reused when possible.

This can be really usefull if you need to quickly rebuild a component with few
patches.

### `please run-test`

**nixpkgs-contril** provides system tests to validate the correct behavior of several
of the packaged components:

- [`allInOne`](./test/all-in-one.nix): Starts OpenContrail services, creates networks and ports and performs a simple traffic test.
- [`tcpFlow`](./test/flows.nix): Generates TCP traffic and checks if the traffic is behaving according to the configured security groups.
- [`udpFlow`](./test/flows.nix): Generates UDP traffic and checks if the traffic is behaving according to the configured security groups.

These tests are executed in virtual machines running in QEMU and can be executed
using the `run-test` command.

```
$ ./please run-test contrail50.test.tcpFlows
[please]: Running "nix-build default.nix -A contrail50.test.tcpFlows"
```
Apart from generating a lot of output on the terminal, each test execution will also
create a `result` output link containing a `log.html` file which contains a pretty-printed
overview of the test.

Please refer to the [NixOS manual](https://nixos.org/nixos/manual/index.html#sec-nixos-tests) for more details.

## Manual Configuration

Usually `please init` will create a fully working setup requiring no further manual configuration. As a fallback and also for more
experienced users who want to do the configuration on their own the following steps can be followed.

**Note**: If `please init` was successful you don't have to run any of the commands described below.

#### 1. Installing Nix

Nix can be installed with the following on-liner:

```
$ curl https://nixos.org/nix/install | sh
```

More detailed information about the installation can be found at https://nixos.org/nix/

#### 2. Configuring the Nix channel

```
$ nix-channel --add https://hydra.nix.corp.cloudwatt.com/jobset/nixpkgs-tungsten/trunk/channel/latest contrail
$ nix-channel --update
```

#### 3. Configuring the binary cache

If there already is a `~/.config/nix/nix.conf` file the `init` command will not try to alter it. In that case
the following needs to be added accordingly:

```
substituters = https://cache.nixos.org https://cache.nix.corp.cloudwatt.com
trusted-substituters = https://cache.nix.corp.cloudwatt.com
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nix.cloudwatt.com:ApPt6XtZeOQ3hNRTSBQx+m6rd8p04G0DQwz0bZfVPL8=
```

## Additional Usage Scenarios

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

All tools can be installed using either `please` or `nix-env` directly:

```
$ ./please install contrailIntrospectCli
```
```
$ nix-env -iA contrailIntrospectCli -f default.nix
```

There is also a nix-shell environment which provides all the tools above without the need to
install them permanently. The shell can be entered from the root of the project tree using `nix-shell`:

```
$ nix-shell
```


## Miscellaneous

### Contributing

Contributions to **nixpkgs-tungsten** through PRs are always welcome. All PRs will be automatically tested by the
[Hydra CI](https://hydra.nix.corp.cloudwatt.com) server.
