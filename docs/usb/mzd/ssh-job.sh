#!/bin/sh
# Provision the service, manage its boot hook, then start/stop only our listener.
set -eu
BASE=$1
USB=$2
REPORT=$3
ACTION=$4
SELECTED=$5
MZD_TARGET_ID=ssh
export MZD_TARGET_ID
mkdir -p "$REPORT"
fail() { echo "ABBRUCH: $*" >&2; exit 1; }
cleanup() { return 0; }
MESSAGE='SSH: keine Aenderung vorgenommen.'
finish() {
    CODE=$?
    trap - 0
    set +e
    if ! cleanup; then CODE=1; MESSAGE='SSH-Abschluss fehlgeschlagen. Bitte run.log pruefen.'; fi
    printf '%s\n' "$MESSAGE" > "$REPORT/summary.txt"
    printf 'exit_code=%s\n' "$CODE" > "$REPORT/status.txt"
    echo "$MESSAGE"
    exit "$CODE"
}
trap finish 0
trap 'exit 130' INT
trap 'exit 143' TERM
. "$BASE/common.sh"
SERVICE="$RESOURCES/aio-rework/services/ssh"
if [ "$ACTION" = install ] || [ "$ACTION" = preflight ]; then
    CHECK_SERVICE="$BASE/ssh"
    if [ -e "$SERVICE" ]; then
        [ -d "$SERVICE" ] && [ ! -L "$SERVICE" ] || fail 'SSH-Dienstverzeichnis ist ungueltig.'
        for F in service.sh sshd_config password.hash; do
            cmp -s "$BASE/ssh/$F" "$SERVICE/$F" || fail 'Vorhandene SSH-Dateien weichen ab. Keine Dateien ueberschrieben; Update muss ausdruecklich unterstuetzt werden.'
        done
        CHECK_SERVICE=$SERVICE
    fi
    # Use the installed identity to recognize our existing listener correctly.
    sh "$CHECK_SERVICE/service.sh" check
fi
if [ "$ACTION" = install ]; then
    ensure_rw "$RESOURCES"
    space "$RESOURCES"
    if [ -e "$SERVICE" ]; then
        [ -d "$SERVICE" ] && [ ! -L "$SERVICE" ] || fail 'SSH-Dienstverzeichnis ist ungueltig.'
        for F in service.sh sshd_config password.hash; do
            cmp -s "$BASE/ssh/$F" "$SERVICE/$F" || fail 'Vorhandene SSH-Dateien weichen ab. Keine Dateien ueberschrieben; Update muss ausdruecklich unterstuetzt werden.'
        done
    else
        mkdir -p "$(dirname "$SERVICE")"
        S="$SERVICE.new-$$"
        mkdir "$S"
        for F in service.sh sshd_config password.hash; do cp "$BASE/ssh/$F" "$S/$F"; done
        chmod 700 "$S/service.sh"
        chmod 600 "$S/sshd_config" "$S/password.hash"
        for F in service.sh sshd_config password.hash; do cmp -s "$BASE/ssh/$F" "$S/$F" || fail 'SSH-Paketkopie unvollstaendig.'; done
        sync
        mv "$S" "$SERVICE"
        sync
    fi
fi
MESSAGE='SSH-Aufgabe nicht vollstaendig abgeschlossen. Boot-Hook, Zustand und Teilberichte pruefen.'
sh "$BASE/file-job.sh" "$BASE" "$USB" "$REPORT/boot-hook" "$ACTION" ssh "$SELECTED" || fail 'SSH-Startdatei konnte nicht bearbeitet werden.'
if [ "$ACTION" = preflight ]; then MESSAGE='SSH-Startdatei geprueft; kein Dienst aktiviert.'; exit 0; fi
if [ -f "$BACKUP/state.txt" ] && grep -qx 'patch=ssh-bringback' "$BACKUP/state.txt"; then
    [ -f "$SERVICE/service.sh" ] || fail 'SSH-Startdatei aktiv, aber Dienstdateien fehlen.'
    ensure_rw "$RESOURCES"
    printf 'enabled\n' > "$SERVICE/enabled"
    sync
    sh "$SERVICE/service.sh" boot "$USB" >/dev/null 2>&1 3>&- 4>&- &
    sleep 2
    sh "$SERVICE/service.sh" status || fail 'Boot-Hook installiert, SSH startet aber nicht. USB-Berichte pruefen; Uninstall bleibt verfuegbar.'
    MESSAGE='SSH installiert: Port 22, Benutzer cmu, Passwort jci. Automatischer Start beim Booten eingerichtet; Fahrzeugtest offen.'
else
    if [ -d "$SERVICE" ]; then
        ensure_rw "$RESOURCES"
        rm -f "$SERVICE/enabled"
        sync
        sh "$SERVICE/service.sh" stop || fail 'SSH-Start entfernt, laufender Dienst konnte nicht vollstaendig beendet werden.'
    fi
    MESSAGE='SSH entfernt: Original-Startdatei wiederhergestellt, eigener Dienst beendet. Interne Originale bleiben erhalten.'
fi
