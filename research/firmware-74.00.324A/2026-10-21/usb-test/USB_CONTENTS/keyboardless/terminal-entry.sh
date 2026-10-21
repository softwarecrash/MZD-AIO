#!/bin/sh
# Executed by /usr/bin/terminal --shell as an executable path, without arguments.
set -u
D=/tmp/mzd-keyboardless-test
IP=$(ip addr show dev wlan0 2>/dev/null | awk '/inet / {split($2,a,"/"); print a[1]; exit}')
if [ -z "$IP" ]; then
    IP=$(ip addr show 2>/dev/null | awk '/inet / {split($2,a,"/"); if(a[1]!="127.0.0.1") {print a[1]; exit}}')
fi
echo 'Keyboardless test: the terminal has executed this script.'
echo 'Test SSH port: 2223 (separate from the previous port 2222).'
echo "Detected address: $IP"
cat /proc/sys/kernel/random/uuid > "$D/run-id.txt"
printf 'terminal_entry_started\n' > "$D/result.txt"
if [ -n "$IP" ] && sh "$D/start-ssh-test.sh" "$IP" > "$D/ssh-start.log" 2>&1; then
    printf 'ssh_started address=%s port=2223\n' "$IP" >> "$D/result.txt"
else
    printf 'ssh_start_failed\n' >> "$D/result.txt"
fi
cat "$D/ssh-start.log" 2>/dev/null
cat "$D/result.txt"
echo 'Confirm the result by a NEW SSH connection to port 2223.'
echo 'Logs: /tmp/mzd-keyboardless-test ; SSH: /tmp/mzd-keyboardless-ssh'
exec /bin/sh
