# Sourced ONLY by start.sh, after firmware/root checks and USB logging.
# BusyBox grep on the CMU has no -x option; compare complete lines with awk.
line_is() { awk -v expected="$1" '$0 == expected {found=1} END {exit !found}' "$2"; }
# Shared file manager: immutable original + active patch list. New apps default to /resources; no apps yet.
TARGET_ID=${MZD_TARGET_ID:-list2}
case "$TARGET_ID" in
list2)
TARGET=/jci/gui/common/controls/List2/js/List2Ctrl.js
RELATIVE=jci/gui/common/controls/List2/js/List2Ctrl.js
FILE_PATCHES='list-beep shorter-delay list-loop'
ORIGINAL=e111883b9dcbeb6bb154521826fcacac
;;
mainmenu)
TARGET=/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js
RELATIVE=jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js
FILE_PATCHES='main-menu-loop'
ORIGINAL=40ccb293b8c6f80960f0b953dd2e173e
;;
ssh)
TARGET=/jci/scripts/stage_wifi.sh
RELATIVE=jci/scripts/stage_wifi.sh
FILE_PATCHES='ssh-bringback'
ORIGINAL=d740449dea568696660a62fce0fb35bd
;;
*) fail 'Unknown file group.' ;;
esac
RESOURCES=/tmp/mnt/resources
ROOT_MOUNT=/
MOUNTS=/proc/mounts
LOCK=/tmp/mzd-aio-rework.lock
LEGACY_BEEP=bb290d22840f82b1be14400ddb41f1b0
BACKUP="$RESOURCES/aio-rework/backups/74.00.324A-EU/$RELATIVE.backup"
ROOT_CHANGED=0
RES_CHANGED=0
LOCKED=0
STATE_STAGE=''
TXN_STAGE=''
STAGE=''
BACKUP_STAGE=''
for tool in awk cp mv rm rmdir sed sync mount df dirname; do command -v "$tool" >/dev/null || fail "Missing tool: $tool"; done
hash() { md5sum "$1" | awk '{print $1}'; }
matches() { [ -f "$1" ] && [ ! -L "$1" ] && [ "$(hash "$1")" = "$2" ]; }
readonly_mount() {
    awk -v p="$1" '$2==p && $3!="rootfs" {n++; split($4,a,","); for(i in a) if(a[i]=="ro") ro=1} END {if(n!=1) exit 2; exit !ro}' "$MOUNTS"
}
ensure_rw() {
    POINT=$1
    if readonly_mount "$POINT"; then
        mount -o remount,rw "$POINT" || fail "Partition is not writable: $POINT"
        if [ "$POINT" = "$ROOT_MOUNT" ]; then ROOT_CHANGED=1; else RES_CHANGED=1; fi
    else
        RC=$?
        [ "$RC" = 1 ] || fail "Mount point is ambiguous: $POINT"
    fi
    if readonly_mount "$POINT"; then fail "Partition remains read-only: $POINT"; else [ "$?" = 1 ] || fail 'Mount check failed.'; fi
}
cleanup() {
    CLEANUP_FAILED=0
    if [ -n "$STAGE" ] && [ -e "$STAGE" ]; then rm -f "$STAGE" || CLEANUP_FAILED=1; fi
    if [ -n "$BACKUP_STAGE" ] && [ -d "$BACKUP_STAGE" ]; then
        rm -f "$BACKUP_STAGE/original" "$BACKUP_STAGE/metadata.txt" || CLEANUP_FAILED=1
        rmdir "$BACKUP_STAGE" || CLEANUP_FAILED=1
    fi
    if [ -n "$STATE_STAGE" ] && [ -e "$STATE_STAGE" ]; then rm -f "$STATE_STAGE" || CLEANUP_FAILED=1; fi
    if [ -n "$TXN_STAGE" ] && [ -d "$TXN_STAGE" ]; then
        rm -f "$TXN_STAGE/before.state" "$TXN_STAGE/after.state" || CLEANUP_FAILED=1
        rmdir "$TXN_STAGE" || CLEANUP_FAILED=1
    fi
    if [ "$ROOT_CHANGED" = 1 ]; then mount -o remount,ro "$ROOT_MOUNT" || CLEANUP_FAILED=1; fi
    if [ "$RES_CHANGED" = 1 ]; then mount -o remount,ro "$RESOURCES" || CLEANUP_FAILED=1; fi
    if [ "$LOCKED" = 1 ]; then rmdir "$LOCK" || CLEANUP_FAILED=1; fi
    return "$CLEANUP_FAILED"
}
valid_backup() {
    matches "$BACKUP/original" "$ORIGINAL" && [ -f "$BACKUP/metadata.txt" ] &&
        line_is 'firmware=74.00.324A-EU' "$BACKUP/metadata.txt" &&
        line_is "target=/$RELATIVE" "$BACKUP/metadata.txt" &&
        line_is "md5=$ORIGINAL" "$BACKUP/metadata.txt"
}
space() {
    FREE=$(df -Pk "$1" | awk 'END {print $4}')
    case "$FREE" in ''|*[!0-9]*) fail 'Could not determine available disk space.' ;; esac
    [ "$FREE" -ge 4096 ] || fail "Less than 4 MiB available on $1. Installation cancelled."
}
