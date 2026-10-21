#!/bin/sh
# Familiar AIO entry; works on FAT32 without executable bits.
HERE=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
exec sh "$HERE/mzd/start.sh" "$@"
