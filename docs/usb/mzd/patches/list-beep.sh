#!/bin/sh
# Apply to a work file. Uninstall/restore are composed centrally from the original.
set -eu
[ "$#" = 3 ] && [ "$1" = apply ] || exit 1
D=$(CDPATH= cd "$(dirname "$0")" && pwd)
[ "$(grep -cF "    this._beep('Long', 'Multicontroller');" "$2")" = 2 ] || exit 1
sed -f "$D/list-beep.sed" "$2" > "$3"
[ "$(grep -cF "//  this._beep('Long', 'Multicontroller');" "$3")" = 2 ] || exit 1
