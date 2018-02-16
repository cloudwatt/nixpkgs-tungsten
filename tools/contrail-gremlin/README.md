Making a dump
=============

First, go to the bathroom.

Err. Just do:

    $ nix-build -A tools.contrailGremlin
    /nix/store/dxlbzdmwafmww3vcvsp01vbzg4w2i8md-contrail-gremlin-2018-01-23-bin

Now you have:

    $ ls /nix/store/dxlbzdmwafmww3vcvsp01vbzg4w2i8md-contrail-gremlin-2018-01-23-bin/bin/
    gremlin-dump  gremlin-probe  gremlin-sync

Run:

    $ /nix/store/dxlbzdmwafmww3vcvsp01vbzg4w2i8md-contrail-gremlin-2018-01-23-bin/gremlin-dump --cassandra IP file.gson


Running checks against the dump
===============================

    $ nix-build -A tools.gremlinChecks
    /nix/store/bbv9fgrnxgkfps1mh7as7bj09fmwbbcr-gremlin-checks
    $ /nix/store/bbv9fgrnxgkfps1mh7as7bj09fmwbbcr-gremlin-checks/bin/gremlin-checks file.gson

And voilà!

Docs
====

More infos at https://github.com/eonpatapon/contrail-gremlin
