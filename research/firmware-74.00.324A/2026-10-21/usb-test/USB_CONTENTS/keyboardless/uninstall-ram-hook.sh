#!/bin/sh
set -eu
D=/tmp/mzd-keyboardless-test
TARGET=/jci/scripts/startSystemScripts.sh
if awk -v p="$TARGET" '$2==p {f=1} END {exit !f}' /proc/mounts; then
    cmp -s "$TARGET" "$D/diagnostic-hook.sh" || { echo 'Unexpected mount contents; stopping.' >&2; exit 1; }
    umount "$TARGET"
fi
echo 'Original diagnostic entry restored. Test logs remain under /tmp.'
if [ -f /tmp/mzd-keyboardless-ssh/stop.sh ]; then
    sh /tmp/mzd-keyboardless-ssh/stop.sh
fi
