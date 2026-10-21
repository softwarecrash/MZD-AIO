#!/bin/sh
# Temporary key-only SSH for legacy Mazda CMU. Not vehicle-tested.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
fail() { echo "ERROR: $*" >&2; exit 1; }
IP=${1:-}
case "$IP" in ''|*[!0-9.]*|.*|*.) fail "Usage: sh start-ssh.sh CMU_IPV4";; esac
printf '%s\n' "$IP" | awk -F. 'NF!=4 {exit 1} {for(i=1;i<=4;i++) if($i=="" || $i+0>255) exit 1}' || fail "Invalid IPv4"
[ "$(id -u)" = 0 ] || fail "Terminal has no root privileges"
for t in sshd ssh-keygen iptables awk sed tr; do command -v "$t" >/dev/null 2>&1 || fail "Missing command: $t"; done
SSHD=$(command -v sshd)
BASE=$(CDPATH= cd "$(dirname "$0")" && pwd)
KEY="$BASE/mazda.pub"
[ -s "$KEY" ] || fail "mazda.pub is missing next to start-ssh.sh"
# Use an existing UID-0 account with an interactive shell. Never alter passwd/shadow.
LOGIN=$(awk -F: '$1=="cmu" && $3==0 && $7 ~ /\/sh$/ {print $1; exit}' /etc/passwd)
if [ -z "$LOGIN" ]; then LOGIN=$(awk -F: '$3==0 && $7 ~ /\/(ba)?sh$/ {print $1; exit}' /etc/passwd); fi
[ -n "$LOGIN" ] || fail "No supported existing root account"
HASH=$(awk -F: -v u="$LOGIN" '$1==u {print $2;exit}' /etc/passwd)
if [ "$HASH" = x ]; then
  [ -r /etc/shadow ] || fail "Cannot inspect account status"
  HASH=$(awk -F: -v u="$LOGIN" '$1==u {print $2;exit}' /etc/shadow)
fi
case "$HASH" in ''|x|'!'*|'*'*) fail "Account is locked/empty/unresolved. No password file changed. Needs device-specific review.";; esac
unset HASH
D=/tmp/mzd-ssh
[ ! -e "$D" ] || fail "$D already exists; stop prior session first"
umask 077
mkdir "$D"
RULE=0
PID=
cleanup_failure() {
  code=$?
  trap - EXIT
  if [ "$code" -ne 0 ]; then
    if [ -n "$PID" ]; then kill "$PID" 2>/dev/null || :; fi
    if [ "$RULE" = 1 ]; then iptables -D INPUT -d "$IP" -p tcp --dport 2222 -j ACCEPT || :; fi
    echo "Setup stopped. No OEM files were replaced. Temporary files: $D" >&2
  fi
  exit "$code"
}
trap cleanup_failure EXIT
tr -d '\r' < "$KEY" > "$D/authorized_keys"
ssh-keygen -l -f "$D/authorized_keys" >/dev/null || fail "Invalid public key"
ssh-keygen -q -t rsa -b 2048 -N '' -f "$D/host_rsa"
cat > "$D/sshd_config" <<EOF
Port 2222
AddressFamily inet
ListenAddress $IP
Protocol 2
HostKey $D/host_rsa
PidFile $D/sshd.pid
AuthorizedKeysFile $D/authorized_keys
AllowUsers $LOGIN
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitEmptyPasswords no
UsePAM no
UsePrivilegeSeparation no
StrictModes no
UseDNS no
PrintLastLog no
PrintMotd no
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
LogLevel VERBOSE
EOF
if [ -x /usr/libexec/sftp-server ]; then
  echo 'Subsystem sftp /usr/libexec/sftp-server' >> "$D/sshd_config"
elif [ -x /usr/lib/openssh/sftp-server ]; then
  echo 'Subsystem sftp /usr/lib/openssh/sftp-server' >> "$D/sshd_config"
fi
"$SSHD" -t -f "$D/sshd_config"
# Keep stderr logging and PID/config in /tmp; do not replace stock SSH service.
"$SSHD" -D -e -f "$D/sshd_config" > "$D/sshd.log" 2>&1 &
PID=$!
echo "$PID" > "$D/launcher.pid"
sleep 1
kill -0 "$PID" 2>/dev/null || { cat "$D/sshd.log"; fail "sshd did not start"; }
iptables -I INPUT 1 -d "$IP" -p tcp --dport 2222 -j ACCEPT
RULE=1
cat > "$D/stop.sh" <<EOF
#!/bin/sh
kill $PID
iptables -D INPUT -d $IP -p tcp --dport 2222 -j ACCEPT
echo "Temporary SSH stopped. Files remain in $D until reboot."
EOF
echo "SSH started: user=$LOGIN address=$IP port=2222"
echo "Host fingerprint (compare on notebook):"
ssh-keygen -l -f "$D/host_rsa.pub"
echo "Stop: sh $D/stop.sh"
echo "No password required: use the PRIVATE key kept on the notebook."
echo "If blocked later, inspect firewall/log; do not disable the complete firewall."
echo "No persistence: access must be set up again after full reboot."
trap - EXIT
exit 0
