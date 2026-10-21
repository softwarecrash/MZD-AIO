#!/bin/sh

export XDG_RUNTIME_DIR=/tmp
export XDG_CONFIG_HOME=/tmp/root/
export SHELL='/bin/sh'

#load USB HID module for keyboard
modprobe usbhid

# westin-terminal now requires /root/.config/weston.ini but works when empty
echo "" > /tmp/root/weston.ini

# start terminal in full screen mode
/usr/bin/terminal -f > /dev/null &

# sleep time needed for surface to spawn
sleep 1

# set focus to westin-terminal
ivi-shell -f "Wayland Terminal" > /dev/null

# set z layer for westin-terminal
ivi-shell -z "Wayland Terminal":10000 > /dev/null &

# set alpha value for westin-terminal
ivi-shell -a "Wayland Terminal":255 > /dev/null &

exit 0
