#!/bin/sh
# Internal implementation; user entry: sh /mnt/sda1/tweaks.sh
# Shared entry for preflight, Install, Uninstall and Full System Restore.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
umask 077
BASE=$(CDPATH= cd "$(dirname "$0")" && pwd)
USB=$(CDPATH= cd "$BASE/.." && pwd -P)
fail() { echo "ABBRUCH: $*" >&2; exit 1; }
USB_CHANGED=0
# The original device inventory shows that a USB may initially be mounted ro.
if awk -v p="$USB" '$2==p {split($4,a,","); for(i in a) if(a[i]=="ro") found=1} END {exit !found}' /proc/mounts; then
    mount -o remount,rw "$USB" || fail 'Start-USB konnte nicht beschreibbar eingebunden werden.'
    USB_CHANGED=1
fi
trap 'if [ "$USB_CHANGED" = 1 ]; then sync; mount -o remount,ro "$USB"; fi' 0
# Resolve the package location, never the caller's current directory.
# Open the USB log BEFORE root, firmware or selection checks can fail.
STAMP=$(date +%Y%m%d-%H%M%S 2>/dev/null || printf undated)
REPORT="$USB/reports/$STAMP-$$"
mkdir -p "$USB/reports" && mkdir "$REPORT" || fail 'Berichtsordner auf dem Startmedium nicht anlegbar. Kein interner Ersatzspeicher.'
: > "$REPORT/run.log" || fail 'Startmedium ist nicht beschreibbar. Kein interner Ersatzspeicher.'
exec 3>&1 4>&2
exec > "$REPORT/run.log" 2>&1
cleanup() { return 0; }
MESSAGE='Keine Aenderung vorgenommen. Details stehen im run.log.'
finish() {
    CODE=$?
    trap - 0
    set +e
    if ! cleanup; then
        CODE=1
        MESSAGE='Abschluss fehlgeschlagen. Bitte run.log pruefen; nicht erneut installieren.'
    fi
    printf '%s\n' "$MESSAGE" > "$REPORT/summary.txt"
    printf 'exit_code=%s\n' "$CODE" > "$REPORT/status.txt"
    printf '\n%s\nexit_code=%s\n' "$MESSAGE" "$CODE"
    sync
    if [ "$USB_CHANGED" = 1 ] && ! mount -o remount,ro "$USB"; then
        CODE=1
        printf 'USB konnte nicht wieder schreibgeschuetzt eingebunden werden.\n' >> "$REPORT/run.log"
        printf 'exit_code=1\n' > "$REPORT/status.txt"
        sync
    fi
    cat "$REPORT/run.log" >&3
    printf '\nBerichte: %s\n' "$REPORT" >&3
    exit "$CODE"
}
trap finish 0
trap 'exit 130' INT
trap 'exit 143' TERM
printf 'MZD-AIO / Startmedium: %s\n' "$USB"
[ "$(id -u)" = 0 ] || fail 'Root-Konsole erforderlich.'
for tool in grep md5sum date mkdir cat; do command -v "$tool" >/dev/null || fail "Werkzeug fehlt: $tool"; done
[ -r "$BASE/originals.md5" ] || fail 'Original-Pruefsummen fehlen.'
grep -qx 'JCI_SW_VER="MAZ_CMU-150_74.00.324"' /jci/version.ini || fail 'Nicht Firmware 74.00.324.'
grep -qx 'JCI_SW_VER_PATCH="A"' /jci/version.ini || fail 'Nicht Patchstand A.'
grep -qx 'JCI_SW_FLAVOR="cmu150_EU"' /jci/version.ini || fail 'Nicht Region EU.'
ACTION=preflight
if [ -f "$BASE/action.txt" ]; then ACTION=$(cat "$BASE/action.txt"); fi
case "${1:-}" in '') ;; --restore-all) ACTION=restore ;; *) fail 'Unbekannter Startparameter.' ;; esac
case "$ACTION" in preflight|install|uninstall|restore) ;; *) fail 'Unbekannte Aktion.' ;; esac
if [ "$ACTION" != restore ]; then
    [ -r "$BASE/selected.txt" ] || fail 'Auswahldatei fehlt.'
    while IFS= read -r patch || [ -n "$patch" ]; do
        [ -n "$patch" ] || continue
        case "$patch" in -*|*[!a-z0-9-]*) fail 'Ungueltige Tweak-ID.' ;; esac
        grep -qxF "$patch" "$BASE/allowed.txt" || fail "Unbekannte Auswahl: $patch"
        if [ "$ACTION" != preflight ] && [ "$patch" != list-beep ]; then
            fail 'Diese Auswahl ist noch nicht portiert. Keine Aenderung vorgenommen.'
        fi
    done < "$BASE/selected.txt"
    if [ "$ACTION" != preflight ]; then
        grep -qx list-beep "$BASE/selected.txt" || fail 'Bitte mindestens einen portierten Tweak auswaehlen.'
    fi
fi
printf 'Aktion: %s\n' "$ACTION"
[ -r "$BASE/installer.sh" ] || fail 'Installer fehlt.'
. "$BASE/installer.sh"
