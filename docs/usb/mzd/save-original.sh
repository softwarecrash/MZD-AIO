# Sourced by the common file manager after confirmation.
if [ ! -d "$BACKUP" ]; then
    space "$RESOURCES"
    ensure_rw "$RESOURCES"
    PARENT=$(dirname "$BACKUP")
    mkdir -p "$PARENT"
    BACKUP_STAGE="$BACKUP.new-$$"
    mkdir "$BACKUP_STAGE" || fail 'Could not prepare backup.'
    cp -p "$TARGET" "$BACKUP_STAGE/original" || fail 'Internal backup failed.'
    matches "$BACKUP_STAGE/original" "$ORIGINAL" || fail 'Internal backup is incomplete.'
    printf 'firmware=74.00.324A-EU\ntarget=/%s\nmd5=%s\n' "$RELATIVE" "$ORIGINAL" > "$BACKUP_STAGE/metadata.txt"
    sync
    [ ! -e "$BACKUP" ] || fail 'Backup destination was created by another process.'
    mv "$BACKUP_STAGE" "$BACKUP" || fail 'Could not complete internal backup.'
    BACKUP_STAGE=''
    sync
fi
valid_backup || fail 'Internal original backup verification failed.'
USB_BACKUP="$USB/backups/74.00.324A-EU/$RELATIVE.backup"
mkdir -p "$USB_BACKUP"
# Never overwrite a different USB original, including a leftover from another CMU.
if [ -e "$USB_BACKUP/original" ]; then
    matches "$USB_BACKUP/original" "$ORIGINAL" || fail 'USB backup is corrupted. Use a different USB drive.'
else
    cp "$BACKUP/original" "$USB_BACKUP/original" || fail 'USB backup failed.'
fi
cp "$BACKUP/metadata.txt" "$USB_BACKUP/metadata.txt"
matches "$USB_BACKUP/original" "$ORIGINAL" || fail 'USB backup is incomplete.'
sync
