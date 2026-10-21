# Sourced by start.sh. One user confirmation, isolated cleanup for each file.
DISPATCH_LOCK=/tmp/mzd-aio-dispatch.lock
mkdir "$DISPATCH_LOCK" || fail 'Ein anderer Installer laeuft bereits.'
DISPATCH_LOCKED=1
cleanup() { if [ "${DISPATCH_LOCKED:-0}" = 1 ]; then rmdir "$DISPATCH_LOCK"; fi; }
if [ "$ACTION" != preflight ]; then
    printf '\nAktion: %s\n' "$ACTION" >&3
    if [ "$ACTION" = restore ]; then printf 'Full System Restore: alle verwalteten Dateigruppen.\n' >&3; else cat "$BASE/selected.txt" >&3; fi
    printf 'Experimentelle v74-Patches. Fortfahren? j und Enter (sonst Abbruch): ' >&3
    ANSWER=''
    IFS= read -r ANSWER || :
    case "$ANSWER" in j|J|y|Y) ;; *) MESSAGE='Abgebrochen. Keine Aenderung vorgenommen.'; exit 0 ;; esac
fi
MZD_CONFIRMED=1
export MZD_CONFIRMED
if [ "$ACTION" != preflight ]; then
    MESSAGE='Vorgang nicht vollstaendig abgeschlossen. Teilberichte pruefen; es koennen bereits Aenderungen erfolgt sein.'
fi
SELECTED="$BASE/selected.txt"
JOBS=0
if [ "$ACTION" = restore ] || [ "$ACTION" = preflight ] || grep -qEx 'list-beep|shorter-delay' "$SELECTED"; then
    mkdir -p "$REPORT/list2"
    sh "$BASE/file-job.sh" "$BASE" "$USB" "$REPORT/list2" "$ACTION" list2 "$SELECTED" || fail 'Dateigruppe Listen wurde nicht abgeschlossen. Teilberichte pruefen.'
    JOBS=$((JOBS+1))
fi
if [ "$ACTION" = restore ] || grep -qx 'ssh-bringback' "$SELECTED"; then
    sh "$BASE/ssh-job.sh" "$BASE" "$USB" "$REPORT/ssh" "$ACTION" "$SELECTED" || fail 'SSH-Aufgabe wurde nicht abgeschlossen. Teilberichte pruefen.'
    JOBS=$((JOBS+1))
fi
MESSAGE="Aktion abgeschlossen: $JOBS Dateigruppe(n). Ergebnisse stehen in den Teilberichten."
exit 0
