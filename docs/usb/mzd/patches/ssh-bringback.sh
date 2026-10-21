#!/bin/sh
set -eu
[ "$#" = 3 ] && [ "$1" = apply ] || exit 1
[ "$(md5sum "$2" | awk '{print $1}')" = d740449dea568696660a62fce0fb35bd ] || exit 1
cat "$2" > "$3"
printf '%s\n' '# MZD-AIO SSH v1' 'sh /tmp/mnt/resources/aio-rework/services/ssh/service.sh boot >/dev/null 2>&1 &' >> "$3"
