# One managed file may carry several independent patches. No diff/patch needed.
. "$BASE/common.sh"
SELECTED_FILE=${MZD_SELECTED_FILE:-$BASE/selected.txt}
STATE_FILE="$BACKUP/state.txt"
TRANSACTION="$BACKUP/transaction"
has() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
write_state() {
    printf 'format=1\nmd5=%s\n' "$2" > "$3"
    for ID in $FILE_PATCHES; do
        if has "$ID" "$1"; then printf 'patch=%s\n' "$ID" >> "$3"; fi
    done
}
rebuild() {
    BUILD_ACTIVE=$1
    BUILD_OUT=$2
    cp "$SOURCE" "$BUILD_OUT.0"
    BUILD_INDEX=0
    BUILD_INPUT="$BUILD_OUT.0"
    for BUILD_ID in $FILE_PATCHES; do
        if has "$BUILD_ID" "$BUILD_ACTIVE"; then
            BUILD_INDEX=$((BUILD_INDEX + 1))
            BUILD_NEXT="$BUILD_OUT.$BUILD_INDEX"
            sh "$BASE/patches/$BUILD_ID.sh" apply "$BUILD_INPUT" "$BUILD_NEXT" || fail "Patchdefinition passt nicht: $BUILD_ID"
            rm -f "$BUILD_INPUT"
            BUILD_INPUT=$BUILD_NEXT
        fi
    done
    mv "$BUILD_INPUT" "$BUILD_OUT"
}
read_state() {
    RECORD=$1
    [ -f "$RECORD" ] && [ ! -L "$RECORD" ] || fail 'Zustandsdatei fehlt oder ist ein Link.'
    RECORD_HASH=$(sed -n 's/^md5=//p' "$RECORD")
    [ "${#RECORD_HASH}" = 32 ] || fail 'Zustandsdatei ist beschaedigt.'
    case "$RECORD_HASH" in *[!0-9a-f]*) fail 'Ungueltige Zustandspruefsumme.' ;; esac
    RECORD_ACTIVE=''
    for RECORD_ID in $(sed -n 's/^patch=//p' "$RECORD"); do
        has "$RECORD_ID" "$FILE_PATCHES" || fail 'Unbekannter Patch im internen Zustand.'
        RECORD_ACTIVE="$RECORD_ACTIVE $RECORD_ID"
    done
    write_state "$RECORD_ACTIVE" "$RECORD_HASH" "$REPORT/state-canonical.txt"
    cmp -s "$RECORD" "$REPORT/state-canonical.txt" || fail 'Zustandsdatei ist unvollstaendig oder doppelt.'
    rebuild "$RECORD_ACTIVE" "$REPORT/state-check.js"
    matches "$REPORT/state-check.js" "$RECORD_HASH" || fail 'Gespeicherter Zustand passt nicht zu den Patchdefinitionen.'
}
publish_state() {
    ensure_rw "$RESOURCES"
    STATE_STAGE="$STATE_FILE.new-$$"
    if [ -e "$STATE_STAGE" ] || [ -L "$STATE_STAGE" ]; then STATE_STAGE=''; fail 'Zustands-Arbeitsdatei existiert bereits.'; fi
    cp "$1" "$STATE_STAGE" && cmp -s "$1" "$STATE_STAGE" || fail 'Zustand konnte nicht vorbereitet werden.'
    mv -f "$STATE_STAGE" "$STATE_FILE" || fail 'Zustand konnte nicht gespeichert werden. Vorgang beim naechsten Start abgleichen.'
    STATE_STAGE=''
    sync
}
clear_transaction() {
    DONE_TXN="$TRANSACTION.done-$$"
    [ ! -e "$DONE_TXN" ] || fail 'Abschlussverzeichnis existiert bereits.'
    mv "$TRANSACTION" "$DONE_TXN" || fail 'Vorgangsabschluss fehlgeschlagen.'
    rm -f "$DONE_TXN/before.state" "$DONE_TXN/after.state" && rmdir "$DONE_TXN" || fail 'Vorgangsabschluss fehlgeschlagen.'
    sync
}
for tool in cmp; do command -v "$tool" >/dev/null || fail "Werkzeug fehlt: $tool"; done
awk '$2!="/jci/gui/common/controls/List2/js/List2Ctrl.js" && $2!="/jci/scripts/stage_wifi.sh"' "$BASE/originals.md5" > "$REPORT/platform.md5"
md5sum -c "$REPORT/platform.md5" || fail 'Der Konsolen-Dateistand ist unbekannt.'
[ -f "$TARGET" ] && [ ! -L "$TARGET" ] || fail 'Systemdatei fehlt oder ist ein Link.'
mkdir "$LOCK" || fail 'Ein anderer Installer laeuft bereits. Nach Abbruch ggf. CMU neu starten.'
LOCKED=1
CURRENT=$(hash "$TARGET")
SOURCE=$TARGET
if [ -e "$BACKUP" ]; then
    [ ! -L "$BACKUP" ] && valid_backup || fail 'Interne Originalsicherung ist beschaedigt oder unpassend.'
    SOURCE="$BACKUP/original"
elif [ "$CURRENT" != "$ORIGINAL" ]; then
    fail 'Die passende interne Originalsicherung fehlt. Keine Aenderung vorgenommen.'
fi
# An intent record remains until both target and state have been committed.
if [ -e "$TRANSACTION" ]; then
    [ "$ACTION" != preflight ] || fail 'Unterbrochener Vorgang erkannt. Install/Uninstall oder Full System Restore zum Abgleich starten.'
    [ -d "$TRANSACTION" ] && [ ! -L "$TRANSACTION" ] || fail 'Vorgangsprotokoll ist ungueltig.'
    read_state "$TRANSACTION/before.state"
    BEFORE_HASH=$RECORD_HASH
    read_state "$TRANSACTION/after.state"
    AFTER_HASH=$RECORD_HASH
    if [ "$CURRENT" = "$AFTER_HASH" ]; then
        publish_state "$TRANSACTION/after.state"
    elif [ "$CURRENT" = "$BEFORE_HASH" ]; then
        publish_state "$TRANSACTION/before.state"
    else
        fail 'Unterbrochener Vorgang mit unbekannter Systemdatei. Keine Datei ueberschrieben.'
    fi
    clear_transaction
    echo 'Unterbrochener Vorgang wurde mit dem vorhandenen Dateistand abgeglichen.'
fi
ACTIVE=''
if [ -e "$STATE_FILE" ]; then
    read_state "$STATE_FILE"
    [ "$CURRENT" = "$RECORD_HASH" ] || fail 'Systemdatei wurde ausserhalb des Installers geaendert. Keine Aenderung vorgenommen.'
    ACTIVE=$RECORD_ACTIVE
elif [ "$TARGET_ID" = list2 ] && [ "$CURRENT" = "$LEGACY_BEEP" ] && valid_backup; then
    ACTIVE='list-beep'
    rebuild "$ACTIVE" "$REPORT/legacy-check.js"
    matches "$REPORT/legacy-check.js" "$CURRENT" || fail 'Bisheriger Patch konnte nicht zugeordnet werden.'
elif [ "$CURRENT" != "$ORIGINAL" ]; then
    fail 'Unbekannter Dateistand ohne passenden gespeicherten Zustand.'
fi
printf 'Aktive Patches:%s\n' "${ACTIVE:- keine}"
write_state "$ACTIVE" "$CURRENT" "$REPORT/before.state"
if [ "$ACTION" = preflight ]; then
    cp "$REPORT/before.state" "$REPORT/preflight.txt"
    MESSAGE='Pruefung abgeschlossen. Keine Aenderung vorgenommen.'
    exit 0
fi
WANTED=''
for ID in $FILE_PATCHES; do
    ENABLED=0
    if has "$ID" "$ACTIVE"; then ENABLED=1; fi
    case "$ACTION" in
        install) if grep -qxF "$ID" "$SELECTED_FILE"; then ENABLED=1; fi ;;
        uninstall) if grep -qxF "$ID" "$SELECTED_FILE"; then ENABLED=0; fi ;;
        restore) ENABLED=0 ;;
    esac
    if [ "$ENABLED" = 1 ]; then WANTED="$WANTED $ID"; fi
done
printf 'Gewuenschte Patches:%s\n' "${WANTED:- keine}"
if [ "$CURRENT" = "$ORIGINAL" ] && [ -z "$WANTED" ] && [ ! -e "$STATE_FILE" ]; then
    MESSAGE='Originalzustand bereits vorhanden. Keine Aenderung erforderlich.'
    exit 0
fi
if [ "${MZD_CONFIRMED:-0}" != 1 ]; then
    printf '\nAktion: %s\nExperimentelle v74-Patches, Fahrzeugtest offen.\n' "$ACTION" >&3
    printf 'Fortfahren? j eingeben und Enter druecken (sonst Abbruch): ' >&3
    ANSWER=''
    IFS= read -r ANSWER || :
    case "$ANSWER" in j|J|y|Y) ;; *) MESSAGE='Abgebrochen. Keine Aenderung vorgenommen.'; exit 0 ;; esac
fi
space "$USB"
. "$BASE/save-original.sh"
SOURCE="$BACKUP/original"
rebuild "$WANTED" "$REPORT/desired.js"
DESIRED=$(hash "$REPORT/desired.js")
write_state "$WANTED" "$DESIRED" "$REPORT/after.state"
if [ "$CURRENT" = "$DESIRED" ]; then
    publish_state "$REPORT/after.state"
    MESSAGE='Gewuenschter Zustand bereits vorhanden. Sicherungen und aktive Patches geprueft.'
    exit 0
fi
space "$ROOT_MOUNT"
space "$RESOURCES"
cp "$TARGET" "$REPORT/before.js"
matches "$REPORT/before.js" "$CURRENT" || fail 'Rueckfallsicherung unvollstaendig.'
ensure_rw "$RESOURCES"
TXN_STAGE="$TRANSACTION.new-$$"
mkdir "$TXN_STAGE"
cp "$REPORT/before.state" "$TXN_STAGE/before.state"
cp "$REPORT/after.state" "$TXN_STAGE/after.state"
cmp -s "$REPORT/before.state" "$TXN_STAGE/before.state" && cmp -s "$REPORT/after.state" "$TXN_STAGE/after.state" || fail 'Vorgangsprotokoll unvollstaendig.'
sync
mv "$TXN_STAGE" "$TRANSACTION"
TXN_STAGE=''
sync
ensure_rw "$ROOT_MOUNT"
STAGE="$(dirname "$TARGET")/.mzd-aio-$$.new"
if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Temporaeres Dateiziel ist bereits vorhanden.'; fi
cp -p "$BACKUP/original" "$STAGE"
cat "$REPORT/desired.js" > "$STAGE"
matches "$STAGE" "$DESIRED" || fail 'Ergebnis passt nicht zum vorbereiteten Dateistand.'
sync
matches "$TARGET" "$CURRENT" || fail 'Systemdatei hat sich waehrend der Installation geaendert.'
mv -f "$STAGE" "$TARGET"
STAGE=''
MESSAGE='Datei wurde geaendert; Vorgangsabschluss steht aus. Naechster Start erkennt den Vorgang.'
sync
if ! matches "$TARGET" "$DESIRED"; then
    STAGE="$(dirname "$TARGET")/.mzd-aio-$$.rollback"
    if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Ruecknahme-Dateiziel ist bereits vorhanden.'; fi
    cp -p "$BACKUP/original" "$STAGE" && cat "$REPORT/before.js" > "$STAGE" && matches "$STAGE" "$CURRENT" && mv -f "$STAGE" "$TARGET" && sync && matches "$TARGET" "$CURRENT" || fail 'Ruecknahme nach Schreibfehler fehlgeschlagen. CMU nicht neu starten; run.log auswerten.'
    STAGE=''
    publish_state "$REPORT/before.state"
    clear_transaction
    MESSAGE='Schreibpruefung fehlgeschlagen. Vorheriger Dateistand wurde wiederhergestellt.'
    fail "$MESSAGE"
fi
publish_state "$REPORT/after.state"
clear_transaction
case "$ACTION" in
    restore) MESSAGE='Original erfolgreich wiederhergestellt. CMU bitte selbst neu starten.' ;;
    uninstall) MESSAGE='Ausgewaehlte Patches entfernt. Andere Patches bleiben erhalten. CMU bitte selbst neu starten.' ;;
    *) MESSAGE='Erfolgreich installiert. Andere Patches bleiben erhalten. CMU bitte selbst neu starten.' ;;
esac
exit 0
