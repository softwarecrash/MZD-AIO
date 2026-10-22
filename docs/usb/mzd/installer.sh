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
            sh "$BASE/patches/$BUILD_ID.sh" apply "$BUILD_INPUT" "$BUILD_NEXT" || fail "Patch definition does not match: $BUILD_ID"
            rm -f "$BUILD_INPUT"
            BUILD_INPUT=$BUILD_NEXT
        fi
    done
    mv "$BUILD_INPUT" "$BUILD_OUT"
}
read_state() {
    RECORD=$1
    [ -f "$RECORD" ] && [ ! -L "$RECORD" ] || fail 'State file is missing or is a symbolic link.'
    RECORD_HASH=$(sed -n 's/^md5=//p' "$RECORD")
    [ "${#RECORD_HASH}" = 32 ] || fail 'State file is corrupted.'
    case "$RECORD_HASH" in *[!0-9a-f]*) fail 'Invalid state checksum.' ;; esac
    RECORD_ACTIVE=''
    for RECORD_ID in $(sed -n 's/^patch=//p' "$RECORD"); do
        has "$RECORD_ID" "$FILE_PATCHES" || fail 'Unknown patch in internal state.'
        RECORD_ACTIVE="$RECORD_ACTIVE $RECORD_ID"
    done
    write_state "$RECORD_ACTIVE" "$RECORD_HASH" "$REPORT/state-canonical.txt"
    cmp -s "$RECORD" "$REPORT/state-canonical.txt" || fail 'State file is incomplete or contains duplicate entries.'
    rebuild "$RECORD_ACTIVE" "$REPORT/state-check.js"
    matches "$REPORT/state-check.js" "$RECORD_HASH" || fail 'Saved state does not match the patch definitions.'
}
publish_state() {
    ensure_rw "$RESOURCES"
    STATE_STAGE="$STATE_FILE.new-$$"
    if [ -e "$STATE_STAGE" ] || [ -L "$STATE_STAGE" ]; then STATE_STAGE=''; fail 'Temporary state file already exists.'; fi
    cp "$1" "$STATE_STAGE" && cmp -s "$1" "$STATE_STAGE" || fail 'Could not prepare state.'
    mv -f "$STATE_STAGE" "$STATE_FILE" || fail 'Could not save state. Reconcile the operation on the next run.'
    STATE_STAGE=''
    sync
}
clear_transaction() {
    DONE_TXN="$TRANSACTION.done-$$"
    [ ! -e "$DONE_TXN" ] || fail 'Transaction completion directory already exists.'
    mv "$TRANSACTION" "$DONE_TXN" || fail 'Could not finalize the transaction.'
    rm -f "$DONE_TXN/before.state" "$DONE_TXN/after.state" && rmdir "$DONE_TXN" || fail 'Could not finalize the transaction.'
    sync
}
for tool in cmp; do command -v "$tool" >/dev/null || fail "Missing tool: $tool"; done
awk '$2!="/jci/gui/common/controls/List2/js/List2Ctrl.js" && $2!="/jci/scripts/stage_wifi.sh"' "$BASE/originals.md5" > "$REPORT/platform.md5"
md5sum -c "$REPORT/platform.md5" || fail 'Console files do not match the known versions.'
[ -f "$TARGET" ] && [ ! -L "$TARGET" ] || fail 'System file is missing or is a symbolic link.'
mkdir "$LOCK" || fail 'Another installer is already running. If a previous run was interrupted, restart the CMU if necessary.'
LOCKED=1
CURRENT=$(hash "$TARGET")
SOURCE=$TARGET
if [ -e "$BACKUP" ]; then
    [ ! -L "$BACKUP" ] && valid_backup || fail 'Internal original backup is corrupted or does not match.'
    SOURCE="$BACKUP/original"
elif [ "$CURRENT" != "$ORIGINAL" ]; then
    fail 'Matching internal original backup is missing. No changes made.'
fi
# An intent record remains until both target and state have been committed.
if [ -e "$TRANSACTION" ]; then
    [ "$ACTION" != preflight ] || fail 'Interrupted transaction detected. Run Install/Uninstall or Full System Restore to reconcile it.'
    [ -d "$TRANSACTION" ] && [ ! -L "$TRANSACTION" ] || fail 'Transaction journal is invalid.'
    read_state "$TRANSACTION/before.state"
    BEFORE_HASH=$RECORD_HASH
    read_state "$TRANSACTION/after.state"
    AFTER_HASH=$RECORD_HASH
    if [ "$CURRENT" = "$AFTER_HASH" ]; then
        publish_state "$TRANSACTION/after.state"
    elif [ "$CURRENT" = "$BEFORE_HASH" ]; then
        publish_state "$TRANSACTION/before.state"
    else
        fail 'Interrupted transaction with an unknown system file. No files overwritten.'
    fi
    clear_transaction
    echo 'Interrupted transaction reconciled with the current files.'
fi
ACTIVE=''
if [ -e "$STATE_FILE" ]; then
    read_state "$STATE_FILE"
    [ "$CURRENT" = "$RECORD_HASH" ] || fail 'System file was changed outside the installer. No changes made.'
    ACTIVE=$RECORD_ACTIVE
elif [ "$TARGET_ID" = list2 ] && [ "$CURRENT" = "$LEGACY_BEEP" ] && valid_backup; then
    ACTIVE='list-beep'
    rebuild "$ACTIVE" "$REPORT/legacy-check.js"
    matches "$REPORT/legacy-check.js" "$CURRENT" || fail 'Could not identify the existing patch.'
elif [ "$CURRENT" != "$ORIGINAL" ]; then
    fail 'Unknown file version without matching saved state.'
fi
printf 'Active patches:%s\n' "${ACTIVE:- none}"
write_state "$ACTIVE" "$CURRENT" "$REPORT/before.state"
if [ "$ACTION" = preflight ]; then
    cp "$REPORT/before.state" "$REPORT/preflight.txt"
    MESSAGE='Checks completed. No changes made.'
    exit 0
fi
WANTED=''
for ID in $FILE_PATCHES; do
    ENABLED=0
    if has "$ID" "$ACTIVE"; then ENABLED=1; fi
    case "$ACTION" in
        install) if line_is "$ID" "$SELECTED_FILE"; then ENABLED=1; fi ;;
        uninstall) if line_is "$ID" "$SELECTED_FILE"; then ENABLED=0; fi ;;
        restore) ENABLED=0 ;;
    esac
    if [ "$ENABLED" = 1 ]; then WANTED="$WANTED $ID"; fi
done
printf 'Requested patches:%s\n' "${WANTED:- none}"
if [ "$CURRENT" = "$ORIGINAL" ] && [ -z "$WANTED" ] && [ ! -e "$STATE_FILE" ]; then
    MESSAGE='Original state already present. No changes required.'
    exit 0
fi
if [ "${MZD_CONFIRMED:-0}" != 1 ]; then
    printf '\nAction: %s\nExperimental v74 patches; vehicle testing pending.\n' "$ACTION" >&3
    printf 'Continue? Type y and press Enter (otherwise cancel): ' >&3
    ANSWER=''
    IFS= read -r ANSWER || :
    case "$ANSWER" in j|J|y|Y) ;; *) MESSAGE='Cancelled. No changes made.'; exit 0 ;; esac
fi
space "$USB"
. "$BASE/save-original.sh"
SOURCE="$BACKUP/original"
rebuild "$WANTED" "$REPORT/desired.js"
DESIRED=$(hash "$REPORT/desired.js")
write_state "$WANTED" "$DESIRED" "$REPORT/after.state"
if [ "$CURRENT" = "$DESIRED" ]; then
    publish_state "$REPORT/after.state"
    MESSAGE='Requested state already present. Backups and active patches verified.'
    exit 0
fi
space "$ROOT_MOUNT"
space "$RESOURCES"
cp "$TARGET" "$REPORT/before.js"
matches "$REPORT/before.js" "$CURRENT" || fail 'Rollback backup is incomplete.'
ensure_rw "$RESOURCES"
TXN_STAGE="$TRANSACTION.new-$$"
mkdir "$TXN_STAGE"
cp "$REPORT/before.state" "$TXN_STAGE/before.state"
cp "$REPORT/after.state" "$TXN_STAGE/after.state"
cmp -s "$REPORT/before.state" "$TXN_STAGE/before.state" && cmp -s "$REPORT/after.state" "$TXN_STAGE/after.state" || fail 'Transaction journal is incomplete.'
sync
mv "$TXN_STAGE" "$TRANSACTION"
TXN_STAGE=''
sync
ensure_rw "$ROOT_MOUNT"
STAGE="$(dirname "$TARGET")/.mzd-aio-$$.new"
if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Temporary destination file already exists.'; fi
cp -p "$BACKUP/original" "$STAGE"
cat "$REPORT/desired.js" > "$STAGE"
matches "$STAGE" "$DESIRED" || fail 'Result does not match the prepared file.'
sync
matches "$TARGET" "$CURRENT" || fail 'System file changed during installation.'
mv -f "$STAGE" "$TARGET"
STAGE=''
MESSAGE='File changed; transaction finalization pending. The next run will detect this transaction.'
sync
if ! matches "$TARGET" "$DESIRED"; then
    STAGE="$(dirname "$TARGET")/.mzd-aio-$$.rollback"
    if [ -e "$STAGE" ] || [ -L "$STAGE" ]; then STAGE=''; fail 'Rollback destination file already exists.'; fi
    cp -p "$BACKUP/original" "$STAGE" && cat "$REPORT/before.js" > "$STAGE" && matches "$STAGE" "$CURRENT" && mv -f "$STAGE" "$TARGET" && sync && matches "$TARGET" "$CURRENT" || fail 'Rollback after write failure failed. Do not restart the CMU; inspect run.log.'
    STAGE=''
    publish_state "$REPORT/before.state"
    clear_transaction
    MESSAGE='Write verification failed. Previous file restored.'
    fail "$MESSAGE"
fi
publish_state "$REPORT/after.state"
clear_transaction
case "$ACTION" in
    restore) MESSAGE='Original restored successfully. Restart the CMU manually.' ;;
    uninstall) MESSAGE='Selected patches removed. Other patches are preserved. Restart the CMU manually.' ;;
    *) MESSAGE='Installed successfully. Other patches are preserved. Restart the CMU manually.' ;;
esac
exit 0
