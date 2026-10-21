# Sourced by the common file manager after confirmation.
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
