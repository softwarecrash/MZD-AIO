#!/bin/sh
# Compose after beep/delay without replacing their changes.
set -eu
[ "$#" = 3 ] && [ "$1" = apply ] || exit 1
D=$(CDPATH= cd "$(dirname "$0")" && pwd)
if grep -qF 'List2Ctrl.prototype._aioWrapListFocus' "$2"; then exit 1; fi
awk -v helper="$D/list-loop-helper.js" -f "$D/list-loop.awk" "$2" > "$3"
