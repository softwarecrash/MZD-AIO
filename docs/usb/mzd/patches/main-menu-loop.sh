#!/bin/sh
# Rebuild centrally from the verified original; change only focus boundaries.
set -eu
[ "$#" = 3 ] && [ "$1" = apply ] || exit 1
D=$(CDPATH= cd "$(dirname "$0")" && pwd)
[ "$(md5sum "$2" | awk '{print $1}')" = 40ccb293b8c6f80960f0b953dd2e173e ] || exit 1
sed -f "$D/main-menu-loop.sed" "$2" > "$3"
[ "$(md5sum "$3" | awk '{print $1}')" = ae272c9befc1350b93f23511568f13c7 ] || exit 1
