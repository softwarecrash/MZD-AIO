#!/bin/sh
# Temporary bind-mount replacement; OEM file on flash is preserved.
D=/tmp/mzd-keyboardless-test
if [ "${1:-}" = 11 ]; then
    sh "$D/launch-terminal.sh"
else
    exec /bin/sh "$D/startSystemScripts.original.sh" "$@"
fi
