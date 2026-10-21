#!/bin/sh
# Independent SSH listener. Factory passwd and OEM sshd are never rewritten.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
SELF_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
SELF="$SELF_DIR/service.sh"
RAM=/tmp/mzd-aio-ssh
ACCOUNT=/config-mfg/passwd
PASSWD_LINK=/etc/passwd
MOUNTS=/proc/mounts
PROC=/proc
CHAIN=MZD_AIO_SSH
CONFIG="$SELF_DIR/sshd_config"
LOG=''
write_log() { if [ -n "$LOG" ]; then printf '%s\n' "$*" >> "$LOG" 2>/dev/null || :; fi; }
fail() { echo "SSH: $*" >&2; write_log "SSH: $*"; exit 1; }
owned_alive() {
    [ -f "$1" ] || return 1
    PID=$(cat "$1")
    case "$PID" in ''|*[!0-9]*) return 1 ;; esac
    [ "$PID" -gt 1 ] && kill -0 "$PID" 2>/dev/null && tr '\000' ' ' < "$PROC/$PID/cmdline" | grep -qF "$2"
}
port_busy() {
    PORTS=$(netstat -lnt) || fail 'Belegte Ports konnten nicht geprueft werden.'
    printf '%s\n' "$PORTS" | awk '$1 ~ /^tcp/ {n=split($4,a,":"); if(a[n]==22) found=1} END {exit !found}'
}
account_mounted() { awk -v p="$ACCOUNT" '$2==p {f=1} END {exit !f}' "$MOUNTS"; }
prerequisites() {
    [ "$(id -u)" = 0 ] || fail 'Root-Konsole erforderlich.'
    for T in sshd awk grep sed tr cmp mount umount iptables netstat readlink; do command -v "$T" >/dev/null || fail "Werkzeug fehlt: $T"; done
    [ "$(readlink "$PASSWD_LINK")" = "$ACCOUNT" ] || fail 'Unbekannte Kontenablage.'
    awk -F: '$1=="cmu" {n++; if(NF!=7 || $3!=0 || $7!="/bin/sh") bad=1} END {exit !(n==1 && !bad)}' "$ACCOUNT" || fail 'cmu-Konto entspricht nicht dem geprueften Aufbau.'
    [ -s /etc/ssh/ssh_host_rsa_key ] || fail 'OEM-Hostschluessel fehlt.'
    [ -s "$SELF_DIR/password.hash" ] || fail 'Passwortdefinition fehlt.'
    sshd -t -f "$CONFIG" || fail 'SSH-Konfiguration ist nicht verwendbar.'
    iptables -S INPUT >/dev/null || fail 'Firewall kann nicht geprueft werden.'
}
firewall() {
    if ! iptables -S "$CHAIN" >/dev/null 2>&1; then
        iptables -N "$CHAIN" || return 1
        iptables -A "$CHAIN" -j ACCEPT || return 1
    fi
    iptables -S INPUT > "$RAM/rules.txt" || return 1
    if ! grep -q -- "-j $CHAIN" "$RAM/rules.txt"; then
        iptables -I INPUT 1 -p tcp --dport 22 -j "$CHAIN" || return 1
    fi
}
remove_firewall() {
    while iptables -D INPUT -p tcp --dport 22 -j "$CHAIN" 2>/dev/null; do :; done
    iptables -F "$CHAIN" 2>/dev/null || :
    iptables -X "$CHAIN" 2>/dev/null || :
    iptables -S INPUT > "$RAM/rules.txt" || return 1
    if grep -q -- "-j $CHAIN" "$RAM/rules.txt"; then return 1; fi
}
teardown() {
    RESULT=0
    if owned_alive "$RAM/daemon.pid" "$CONFIG"; then kill "$PID" || RESULT=1; fi
    if account_mounted; then
        if [ -f "$RAM/owner" ] && [ "$(cat "$RAM/owner")" = "$SELF" ] && cmp -s "$ACCOUNT" "$RAM/passwd"; then
            umount "$ACCOUNT" || RESULT=1
            if command -v nscd >/dev/null; then nscd -i passwd 2>/dev/null || :; fi
        else
            echo 'SSH: Fremde Kontenueberlagerung bleibt unveraendert.' >&2
            RESULT=1
        fi
    fi
    remove_firewall || RESULT=1
    if [ "$RESULT" = 0 ] && [ -d "$RAM" ]; then
        rm -f "$RAM/owner" "$RAM/passwd" "$RAM/supervisor.pid" "$RAM/daemon.pid" "$RAM/sshd.pid" "$RAM/ports.txt" "$RAM/rules.txt"
        rmdir "$RAM" || RESULT=1
    fi
    return "$RESULT"
}
stop_service() {
    if owned_alive "$RAM/supervisor.pid" "$SELF boot"; then
        STOP_PID=$PID
        kill "$STOP_PID"
        N=0
        while kill -0 "$STOP_PID" 2>/dev/null && [ "$N" -lt 10 ]; do sleep 1; N=$((N+1)); done
        if kill -0 "$STOP_PID" 2>/dev/null; then fail 'Eigener SSH-Startprozess beendet sich nicht.'; fi
    fi
    if [ -d "$RAM" ]; then teardown || fail 'SSH konnte nicht vollstaendig beendet werden.'; fi
    echo 'SSH beendet; urspruengliche Konten und Firewallfreigabe wiederhergestellt.'
}
case "${1:-}" in
check)
    prerequisites
    if ! owned_alive "$RAM/supervisor.pid" "$SELF boot" && port_busy; then fail 'Port 22 ist bereits belegt. Fremder Dienst bleibt unveraendert.'; fi
    echo 'SSH-Voraussetzungen geprueft.'; exit 0 ;;
status)
    if owned_alive "$RAM/supervisor.pid" "$SELF boot" && owned_alive "$RAM/daemon.pid" "$CONFIG"; then
        echo 'SSH laeuft: Port 22, Benutzer cmu.'
        if command -v ip >/dev/null; then
            ip addr show 2>/dev/null | awk '/inet / {split($2,a,"/"); if(a[1]!="127.0.0.1") print "Verbinden: ssh cmu@" a[1]}' || :
        fi
        echo 'Falls noch keine Adresse angezeigt wird: WLAN-Verbindung pruefen.'
        exit 0
    fi
    echo 'Eigener SSH-Dienst laeuft nicht.'; exit 1 ;;
stop) stop_service; exit 0 ;;
boot) ;;
*) fail 'Aufruf: service.sh check|boot|status|stop' ;;
esac
[ -f "$SELF_DIR/enabled" ] || exit 0
if owned_alive "$RAM/supervisor.pid" "$SELF boot"; then echo 'Eigener SSH-Dienst laeuft bereits.'; exit 0; fi
if [ -d "$RAM" ]; then stop_service; fi
umask 077
mkdir "$RAM" || fail 'SSH-Zustandsordner kann nicht angelegt werden.'
printf '%s\n' "$SELF" > "$RAM/owner"
printf '%s\n' "$$" > "$RAM/supervisor.pid"
finish() {
    CODE=$?
    trap - 0
    set +e
    teardown || CODE=1
    exit "$CODE"
}
trap finish 0
trap 'exit 0' INT TERM
# Runtime logs only on a matching attached USB; never in internal flash or RAM.
LOG=/dev/null
for U in "${2:-}" /tmp/mnt/sda1 /tmp/mnt/sdb1 /tmp/mnt/sdc1 /tmp/mnt/sdd1; do
    [ -n "$U" ] || continue
    if [ -f "$U/mzd/ssh-log-marker.txt" ] && grep -qx 'MZD-AIO-SSH-v1' "$U/mzd/ssh-log-marker.txt"; then
        D="$U/reports/ssh-$(date +%Y%m%d-%H%M%S)-$$"
        if mkdir -p "$D" && : > "$D/run.log"; then LOG="$D/run.log"; break; fi
    fi
done
prerequisites
if port_busy; then fail 'Port 22 ist bereits belegt. Fremder Dienst bleibt unveraendert.'; fi
account_mounted && fail 'Kontendatei ist bereits ueberlagert. Keine zweite Ueberlagerung.'
PASSWORD_HASH=$(cat "$SELF_DIR/password.hash")
case "$PASSWORD_HASH" in '$5$'*) ;; *) fail 'Unbekanntes Passwortformat.' ;; esac
awk -F: -v h="$PASSWORD_HASH" 'BEGIN {OFS=":"} $1=="cmu" {$2=h} {print}' "$ACCOUNT" > "$RAM/passwd"
unset PASSWORD_HASH
chmod 644 "$RAM/passwd"
mount -o bind "$RAM/passwd" "$ACCOUNT" || fail 'Passwort konnte nicht im RAM eingerichtet werden.'
cmp -s "$RAM/passwd" "$ACCOUNT" || fail 'Kontenueberlagerung konnte nicht bestaetigt werden.'
if command -v nscd >/dev/null; then nscd -i passwd 2>/dev/null || :; fi
sshd -D -e -f "$CONFIG" 2>&1 | while IFS= read -r LINE; do write_log "$LINE"; done &
sleep 1
[ -s "$RAM/sshd.pid" ] || fail 'SSH konnte Port 22 nicht oeffnen.'
DAEMON=$(cat "$RAM/sshd.pid")
case "$DAEMON" in ''|*[!0-9]*) fail 'SSH lieferte keine gueltige Prozessnummer.' ;; esac
printf '%s\n' "$DAEMON" > "$RAM/daemon.pid"
owned_alive "$RAM/daemon.pid" "$CONFIG" || fail 'SSH konnte Port 22 nicht oeffnen.'
firewall || fail 'Port 22 konnte nicht freigegeben werden.'
write_log 'SSH gestartet: Port 22, Benutzer cmu. Anmeldung mit dem vereinbarten Standardpasswort.'
while kill -0 "$DAEMON" 2>/dev/null; do
    firewall || write_log 'Firewall wird beim naechsten Durchlauf erneut geprueft.'
    sleep 5 &
    wait $! || :
done
fail 'SSH-Prozess wurde beendet.'
