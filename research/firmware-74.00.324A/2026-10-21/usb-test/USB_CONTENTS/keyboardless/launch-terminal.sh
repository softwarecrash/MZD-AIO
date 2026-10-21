#!/bin/sh
set -eu
D=/tmp/mzd-keyboardless-test
export XDG_RUNTIME_DIR=/tmp
export XDG_CONFIG_HOME="$D/config"
export SHELL=/bin/sh
mkdir -p "$XDG_CONFIG_HOME"
: > "$XDG_CONFIG_HOME/weston.ini"
echo 'Launching terminal with explicit shell script.' >> "$D/launch.log"
/usr/bin/terminal -f --shell="$D/terminal-entry.sh" >> "$D/window.log" 2>&1 &
echo "$!" > "$D/terminal.pid"
sleep 1
ivi-shell -f 'Wayland Terminal' >> "$D/window.log" 2>&1 || :
ivi-shell -z 'Wayland Terminal':10000 >> "$D/window.log" 2>&1 || :
ivi-shell -a 'Wayland Terminal':255 >> "$D/window.log" 2>&1 || :
