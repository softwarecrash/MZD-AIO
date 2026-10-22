# Sourced by start.sh. One user confirmation, isolated cleanup for each file.
DISPATCH_LOCK=/tmp/mzd-aio-dispatch.lock
mkdir "$DISPATCH_LOCK" || fail 'Another installer is already running.'
DISPATCH_LOCKED=1
cleanup() { if [ "${DISPATCH_LOCKED:-0}" = 1 ]; then rmdir "$DISPATCH_LOCK"; fi; }
if [ "$ACTION" != preflight ]; then
    printf '\nAction: %s\n' "$ACTION" >&3
    if [ "$ACTION" = restore ]; then printf 'Full System Restore: all managed file groups.\n' >&3; else cat "$BASE/selected.txt" >&3; fi
    printf 'Experimental v74 patches. Continue? Type y and press Enter (otherwise cancel): ' >&3
    ANSWER=''
    IFS= read -r ANSWER || :
    case "$ANSWER" in j|J|y|Y) ;; *) MESSAGE='Cancelled. No changes made.'; exit 0 ;; esac
fi
MZD_CONFIRMED=1
export MZD_CONFIRMED
if [ "$ACTION" != preflight ]; then
    MESSAGE='Operation incomplete. Check the individual reports; some changes may already have been applied.'
fi
SELECTED="$BASE/selected.txt"
JOBS=0
if [ "$ACTION" = restore ] || [ "$ACTION" = preflight ] || grep -qEx 'list-beep|shorter-delay|list-loop' "$SELECTED"; then
    mkdir -p "$REPORT/list2"
    sh "$BASE/file-job.sh" "$BASE" "$USB" "$REPORT/list2" "$ACTION" list2 "$SELECTED" || fail 'List file group did not complete. Check the individual reports.'
    JOBS=$((JOBS+1))
fi
if [ "$ACTION" = restore ] || grep -qx 'main-menu-loop' "$SELECTED"; then
    mkdir -p "$REPORT/mainmenu"
    sh "$BASE/file-job.sh" "$BASE" "$USB" "$REPORT/mainmenu" "$ACTION" mainmenu "$SELECTED" || fail 'Main menu file group did not complete. Check the individual reports.'
    JOBS=$((JOBS+1))
fi
if [ "$ACTION" = restore ] || grep -qx 'ssh-bringback' "$SELECTED"; then
    sh "$BASE/ssh-job.sh" "$BASE" "$USB" "$REPORT/ssh" "$ACTION" "$SELECTED" || fail 'SSH task did not complete. Check the individual reports.'
    JOBS=$((JOBS+1))
fi
MESSAGE="Action completed: $JOBS file group(s). Results are in the individual reports."
exit 0
