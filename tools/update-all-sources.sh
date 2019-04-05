#!/bin/bash

SCRIPT=$(readlink -f $0)
export BASEDIR=$(dirname "${SCRIPT}")

update_sources() {
    ${BASEDIR}/sources.sh ${BASEDIR}/sources-$1.lst > ${BASEDIR}/../sources-$1.nix
    echo "$1 update done."
}
export -f update_sources

parallel update_sources ::: R3.2 R4.1 R5.0
