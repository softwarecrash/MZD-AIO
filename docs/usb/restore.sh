#!/bin/sh
# Full System Restore: deliberately independent of the builder selection.
HERE=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
exec sh "$HERE/mzd/start.sh" --restore-all
