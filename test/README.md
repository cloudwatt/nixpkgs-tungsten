The goal is to validate the packaging. This boots a VM, installs, starts
all OpenContrail components and do some basic tests.

To run tests
```
nixpkgs-contrail$ nix-build -A test.contrail
```

You can also build a VM in order to use it interactively
```
nixpkgs-contrail$ nix-build -A test.contrail.driver
nixpkgs-contrail$ QEMU_NET_OPTS="hostfwd=tcp::2222-:22" result/bin/nixos-run-vms

$ ssh -p 2222 root@localhost
Password: root
```

See the Nixos [manual](https://nixos.org/nixos/manual/index.html#sec-nixos-tests) for
more information.
