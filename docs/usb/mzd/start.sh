#!/bin/sh
# Internal implementation; user entry: sh /mnt/sda1/tweaks.sh
# Shared entry for preflight, Install, Uninstall and Full System Restore.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
umask 077
BASE=$(CDPATH= cd "$(dirname "$0")" && pwd)
USB=$(CDPATH= cd "$BASE/.." && pwd -P)
fail() { echo "ERROR: $*" >&2; exit 1; }
USB_CHANGED=0
# The original device inventory shows that a USB may initially be mounted ro.
if awk -v p="$USB" '$2==p {split($4,a,","); for(i in a) if(a[i]=="ro") found=1} END {exit !found}' /proc/mounts; then
    mount -o remount,rw "$USB" || fail 'Could not remount the startup USB drive read-write.'
    USB_CHANGED=1
fi
trap 'if [ "$USB_CHANGED" = 1 ]; then sync; mount -o remount,ro "$USB"; fi' 0
# Resolve the package location, never the caller's current directory.
# Open the USB log BEFORE root, firmware or selection checks can fail.
STAMP=$(date +%Y%m%d-%H%M%S 2>/dev/null || printf undated)
REPORT="$USB/reports/$STAMP-$$"
mkdir -p "$USB/reports" && mkdir "$REPORT" || fail 'Could not create the report directory on the startup medium. No internal storage fallback.'
: > "$REPORT/run.log" || fail 'Startup medium is not writable. No internal storage fallback.'
exec 3>&1 4>&2
exec > "$REPORT/run.log" 2>&1
cleanup() { return 0; }
MESSAGE='No changes made. See run.log for details.'
finish() {
    CODE=$?
    trap - 0
    set +e
    if ! cleanup; then
        CODE=1
        MESSAGE='Cleanup failed. Check run.log; do not reinstall.'
    fi
    printf '%s\n' "$MESSAGE" > "$REPORT/summary.txt"
    printf 'exit_code=%s\n' "$CODE" > "$REPORT/status.txt"
    printf '\n%s\nexit_code=%s\n' "$MESSAGE" "$CODE"
    sync
    if [ "$USB_CHANGED" = 1 ] && ! mount -o remount,ro "$USB"; then
        CODE=1
        printf 'Could not remount the USB drive read-only.\n' >> "$REPORT/run.log"
        printf 'exit_code=1\n' > "$REPORT/status.txt"
        sync
    fi
    cat "$REPORT/run.log" >&3
    printf '\nReports: %s\n' "$REPORT" >&3
    exit "$CODE"
}
trap finish 0
trap 'exit 130' INT
trap 'exit 143' TERM
printf 'MZD-AIO / Startup medium: %s\n' "$USB"
[ "$(id -u)" = 0 ] || fail 'Root shell required.'
for tool in grep md5sum date mkdir cat; do command -v "$tool" >/dev/null || fail "Missing tool: $tool"; done
[ -r "$BASE/originals.md5" ] || fail 'Original checksums are missing.'
grep -qx 'JCI_SW_VER="MAZ_CMU-150_74.00.324"' /jci/version.ini || fail 'Firmware is not 74.00.324.'
grep -qx 'JCI_SW_VER_PATCH="A"' /jci/version.ini || fail 'Patch level is not A.'
grep -qx 'JCI_SW_FLAVOR="cmu150_EU"' /jci/version.ini || fail 'Region is not EU.'
ACTION=preflight
if [ -f "$BASE/action.txt" ]; then ACTION=$(cat "$BASE/action.txt"); fi
case "${1:-}" in '') ;; --restore-all) ACTION=restore ;; *) fail 'Unknown startup argument.' ;; esac
case "$ACTION" in preflight|install|uninstall|restore) ;; *) fail 'Unknown action.' ;; esac
if [ "$ACTION" != restore ]; then
    [ -r "$BASE/selected.txt" ] || fail 'Selection file is missing.'
    while IFS= read -r patch || [ -n "$patch" ]; do
        [ -n "$patch" ] || continue
        case "$patch" in -*|*[!a-z0-9-]*) fail 'Invalid tweak ID.' ;; esac
        grep -qxF "$patch" "$BASE/allowed.txt" || fail "Unknown selection: $patch"
        if [ "$ACTION" != preflight ] && [ "$patch" != list-beep ] && [ "$patch" != shorter-delay ] && [ "$patch" != ssh-bringback ] && [ "$patch" != main-menu-loop ] && [ "$patch" != list-loop ]; then
            fail 'This selection has not been ported yet. No changes made.'
        fi
    done < "$BASE/selected.txt"
    if [ "$ACTION" != preflight ]; then
        grep -qEx "list-beep|shorter-delay|ssh-bringback|main-menu-loop|list-loop" "$BASE/selected.txt" || fail 'Select at least one ported tweak.'
    fi
fi
printf 'Action: %s\n' "$ACTION"
[ -r "$BASE/dispatch.sh" ] || fail 'Installer is missing.'
. "$BASE/dispatch.sh"
