# Sourced ONLY by start.sh, after firmware/root checks and USB logging.
# Registry v1: list-beep only. New apps default to /resources; no apps yet.
TARGET=/jci/gui/common/controls/List2/js/List2Ctrl.js
RELATIVE=jci/gui/common/controls/List2/js/List2Ctrl.js
RESOURCES=/tmp/mnt/resources
ROOT_MOUNT=/
MOUNTS=/proc/mounts
LOCK=/tmp/mzd-aio-rework.lock
ORIGINAL=e111883b9dcbeb6bb154521826fcacac
PATCHED=bb290d22840f82b1be14400ddb41f1b0
BACKUP="$RESOURCES/aio-rework/backups/74.00.324A-EU/$RELATIVE.backup"
ROOT_CHANGED=0
RES_CHANGED=0
LOCKED=0
STAGE=''
BACKUP_STAGE=''
for tool in awk cp mv rm rmdir sed sync mount df dirname; do command -v "$tool" >/dev/null || fail "Werkzeug fehlt: $tool"; done
hash() { md5sum "$1" | awk '{print $1}'; }
matches() { [ -f "$1" ] && [ ! -L "$1" ] && [ "$(hash "$1")" = "$2" ]; }
readonly_mount() {
    awk -v p="$1" '$2==p && $3!="rootfs" {n++; split($4,a,","); for(i in a) if(a[i]=="ro") ro=1} END {if(n!=1) exit 2; exit !ro}' "$MOUNTS"
}
ensure_rw() {
    POINT=$1
    if readonly_mount "$POINT"; then
        mount -o remount,rw "$POINT" || fail "Partition nicht beschreibbar: $POINT"
        if [ "$POINT" = "$ROOT_MOUNT" ]; then ROOT_CHANGED=1; else RES_CHANGED=1; fi
    else
        RC=$?
        [ "$RC" = 1 ] || fail "Mountpunkt nicht eindeutig: $POINT"
    fi
    if readonly_mount "$POINT"; then fail "Partition blieb schreibgeschuetzt: $POINT"; else [ "$?" = 1 ] || fail 'Mountpruefung fehlgeschlagen.'; fi
}
cleanup() {
    CLEANUP_FAILED=0
    if [ -n "$STAGE" ] && [ -e "$STAGE" ]; then rm -f "$STAGE" || CLEANUP_FAILED=1; fi
    if [ -n "$BACKUP_STAGE" ] && [ -d "$BACKUP_STAGE" ]; then
        rm -f "$BACKUP_STAGE/original" "$BACKUP_STAGE/metadata.txt" || CLEANUP_FAILED=1
        rmdir "$BACKUP_STAGE" || CLEANUP_FAILED=1
    fi
    if [ "$ROOT_CHANGED" = 1 ]; then mount -o remount,ro "$ROOT_MOUNT" || CLEANUP_FAILED=1; fi
    if [ "$RES_CHANGED" = 1 ]; then mount -o remount,ro "$RESOURCES" || CLEANUP_FAILED=1; fi
    if [ "$LOCKED" = 1 ]; then rmdir "$LOCK" || CLEANUP_FAILED=1; fi
    return "$CLEANUP_FAILED"
}
valid_backup() {
    matches "$BACKUP/original" "$ORIGINAL" && [ -f "$BACKUP/metadata.txt" ] &&
        grep -qx 'firmware=74.00.324A-EU' "$BACKUP/metadata.txt" &&
        grep -qxF "target=/$RELATIVE" "$BACKUP/metadata.txt" &&
        grep -qx "md5=$ORIGINAL" "$BACKUP/metadata.txt"
}
space() {
    FREE=$(df -Pk "$1" | awk 'END {print $4}')
    case "$FREE" in ''|*[!0-9]*) fail 'Freier Speicher konnte nicht bestimmt werden.' ;; esac
    [ "$FREE" -ge 4096 ] || fail "Weniger als 4 MiB frei auf $1. Keine Installation."
}
# Check untouched launch files separately: List2 may already carry our patch.
awk -v p="/$RELATIVE" '$2!=p' "$BASE/originals.md5" > "$REPORT/platform.md5"
md5sum -c "$REPORT/platform.md5" || fail 'Der Konsolen-Dateistand ist unbekannt.'
[ -f "$TARGET" ] && [ ! -L "$TARGET" ] || fail 'Systemdatei fehlt oder ist ein Link.'
CURRENT=$(hash "$TARGET")
case "$CURRENT" in
    "$ORIGINAL") STATE=original ;;
    "$PATCHED") STATE=installed ;;
    *) STATE=unknown ;;
esac
printf 'Listenpiepsen: %s\n' "$STATE"
if [ "$ACTION" = preflight ]; then
    printf 'firmware=74.00.324A-EU\nlist-beep=%s\n' "$STATE" > "$REPORT/preflight.txt"
    [ "$STATE" != unknown ] || { MESSAGE='Unbekannter Dateistand. Keine Aenderung vorgenommen.'; exit 2; }
    MESSAGE='Pruefung abgeschlossen. Keine Aenderung vorgenommen.'
    exit 0
fi
# A single process manages backups and writes. Never remove another run's lock.
mkdir "$LOCK" || fail 'Ein anderer Installer laeuft bereits. Nach Abbruch ggf. CMU neu starten.'
LOCKED=1
[ "$STATE" != unknown ] || fail 'Systemdatei wurde anderweitig geaendert. Keine Aenderung vorgenommen.'
if [ "$ACTION" = install ]; then DESIRED=$PATCHED; else DESIRED=$ORIGINAL; fi
if [ -e "$BACKUP" ]; then
    [ ! -L "$BACKUP" ] && valid_backup || fail 'Interne Originalsicherung ist beschaedigt oder unpassend. Keine Aenderung vorgenommen.'
elif [ "$STATE" = installed ]; then
    fail 'Die passende interne Originalsicherung fehlt. Keine Wiederherstellung mit fremden Dateien.'
fi
if [ "$ACTION" != install ] && [ "$STATE" = original ]; then
    MESSAGE='Originalzustand bereits vorhanden. Keine Aenderung erforderlich.'
    exit 0
fi
printf '\n%s: Listenpiepsen\nExperimenteller v74-Patch, noch nicht am Fahrzeug bestaetigt.\n' "$ACTION" >&3
printf 'Fortfahren? j eingeben und Enter druecken (sonst Abbruch): ' >&3
ANSWER=''
IFS= read -r ANSWER || :
case "$ANSWER" in j|J|y|Y) ;; *) MESSAGE='Abgebrochen. Keine Aenderung vorgenommen.'; exit 0 ;; esac
space "$USB"
if [ ! -d "$BACKUP" ]; then
    space "$RESOURCES"
    ensure_rw "$RESOURCES"
    PARENT=$(dirname "$BACKUP")
    mkdir -p "$PARENT"
    BACKUP_STAGE="$BACKUP.new-$$"
    mkdir "$BACKUP_STAGE" || fail 'Sicherung konnte nicht vorbereitet werden.'
    cp -p "$TARGET" "$BACKUP_STAGE/original" || fail 'Interne Sicherung fehlgeschlagen.'
    matches "$BACKUP_STAGE/original" "$ORIGINAL" || fail 'Interne Sicherung unvollstaendig.'
    printf 'firmware=74.00.324A-EU\ntarget=/%s\nmd5=%s\n' "$RELATIVE" "$ORIGINAL" > "$BACKUP_STAGE/metadata.txt"
    sync
    [ ! -e "$BACKUP" ] || fail 'Sicherungsziel wurde zwischenzeitlich angelegt.'
    mv "$BACKUP_STAGE" "$BACKUP" || fail 'Interne Sicherung konnte nicht abgeschlossen werden.'
    BACKUP_STAGE=''
    sync
fi
valid_backup || fail 'Pruefung der internen Originalsicherung fehlgeschlagen.'
USB_BACKUP="$USB/backups/74.00.324A-EU/$RELATIVE.backup"
mkdir -p "$USB_BACKUP"
# Never overwrite a different USB original, including a leftover from another CMU.
if [ -e "$USB_BACKUP/original" ]; then
    matches "$USB_BACKUP/original" "$ORIGINAL" || fail 'USB-Sicherung ist beschaedigt. Bitte einen neuen Stick verwenden.'
else
    cp "$BACKUP/original" "$USB_BACKUP/original" || fail 'USB-Sicherung fehlgeschlagen.'
fi
cp "$BACKUP/metadata.txt" "$USB_BACKUP/metadata.txt"
matches "$USB_BACKUP/original" "$ORIGINAL" || fail 'USB-Sicherung unvollstaendig.'
sync
if [ "$CURRENT" = "$DESIRED" ]; then MESSAGE='Tweak bereits installiert. Sicherungen geprueft.'; exit 0; fi
space "$ROOT_MOUNT"
cp "$TARGET" "$REPORT/before.js" || fail 'Rueckfallsicherung auf USB fehlgeschlagen.'
matches "$REPORT/before.js" "$CURRENT" || fail 'Rueckfallsicherung unvollstaendig.'
ensure_rw "$ROOT_MOUNT"
STAGE="$(dirname "$TARGET")/.mzd-aio-$$.new"
if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Temporaeres Dateiziel ist bereits vorhanden.'; fi
cp -p "$TARGET" "$STAGE" || fail 'Arbeitsdatei konnte nicht angelegt werden.'
if [ "$ACTION" = install ]; then
    sed -f "$BASE/list-beep.sed" "$BACKUP/original" > "$STAGE" || fail 'Patch konnte nicht vorbereitet werden.'
else
    cp -p "$BACKUP/original" "$STAGE" || fail 'Original konnte nicht vorbereitet werden.'
fi
matches "$STAGE" "$DESIRED" || fail 'Ergebnis passt nicht zum geprueften Patch.'
sync
matches "$TARGET" "$CURRENT" || fail 'Systemdatei hat sich waehrend der Installation geaendert.'
mv -f "$STAGE" "$TARGET" || fail 'Systemdatei konnte nicht ersetzt werden.'
STAGE=''
MESSAGE='Datei wurde geaendert; Abschlusspruefung steht aus. Bitte run.log pruefen.'
sync
if ! matches "$TARGET" "$DESIRED"; then
    STAGE="$(dirname "$TARGET")/.mzd-aio-$$.rollback"
    if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Ruecknahme-Dateiziel ist bereits vorhanden.'; fi
    cp -p "$BACKUP/original" "$STAGE" && cat "$REPORT/before.js" > "$STAGE" && matches "$STAGE" "$CURRENT" && mv -f "$STAGE" "$TARGET" && sync && matches "$TARGET" "$CURRENT" || fail 'Ruecknahme nach Schreibfehler fehlgeschlagen. CMU nicht neu starten; run.log auswerten.'
    STAGE=''
    MESSAGE='Schreibpruefung fehlgeschlagen. Vorheriger Dateistand wurde wiederhergestellt.'
    fail "$MESSAGE"
fi
if [ "$ACTION" = install ]; then
    MESSAGE='Erfolgreich installiert: Listenpiepsen deaktiviert. CMU bitte selbst neu starten.'
else
    MESSAGE='Original erfolgreich wiederhergestellt. CMU bitte selbst neu starten.'
fi
exit 0
