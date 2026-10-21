#!/bin/sh
# Apply to a work file. Each expected parameter must occur exactly once.
set -eu
[ "$#" = 3 ] && [ "$1" = apply ] || exit 1
D=$(CDPATH= cd "$(dirname "$0")" && pwd)
for TEXT in \
    'autoscrollTier1Timeout :                1500,' \
    'autoscrollTier2Timeout :                5000,' \
    'autoscrollTier1Interval :               500,' \
    'autoscrollTier2Interval :               1000,'; do
    [ "$(grep -cF "$TEXT" "$2")" = 1 ] || exit 1
done
sed -f "$D/shorter-delay.sed" "$2" > "$3"
for TEXT in \
    'autoscrollTier1Timeout :                150,' \
    'autoscrollTier2Timeout :                300,' \
    'autoscrollTier1Interval :               200,' \
    'autoscrollTier2Interval :               300,'; do
    [ "$(grep -cF "$TEXT" "$3")" = 1 ] || exit 1
done
