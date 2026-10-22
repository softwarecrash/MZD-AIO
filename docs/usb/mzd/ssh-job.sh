#!/bin/sh
# Provision the service, manage its boot hook, then start/stop only our listener.
set -eu
BASE=$1
USB=$2
REPORT=$3
ACTION=$4
SELECTED=$5
MZD_TARGET_ID=ssh
export MZD_TARGET_ID
mkdir -p "$REPORT"
fail() { echo "ERROR: $*" >&2; exit 1; }
cleanup() { return 0; }
MESSAGE='SSH: no changes made.'
finish() {
    CODE=$?
    trap - 0
    set +e
    if ! cleanup; then CODE=1; MESSAGE='SSH-Cleanup failed. Check run.log.'; fi
    printf '%s\n' "$MESSAGE" > "$REPORT/summary.txt"
    printf 'exit_code=%s\n' "$CODE" > "$REPORT/status.txt"
    echo "$MESSAGE"
    exit "$CODE"
}
trap finish 0
trap 'exit 130' INT
trap 'exit 143' TERM
. "$BASE/common.sh"
SERVICE="$RESOURCES/aio-rework/services/ssh"
if [ "$ACTION" = install ] || [ "$ACTION" = preflight ]; then
    CHECK_SERVICE="$BASE/ssh"
    if [ -e "$SERVICE" ]; then
        [ -d "$SERVICE" ] && [ ! -L "$SERVICE" ] || fail 'SSH service directory is invalid.'
        for F in service.sh sshd_config password.hash; do
            cmp -s "$BASE/ssh/$F" "$SERVICE/$F" || fail 'Existing SSH files differ. No files overwritten; updates must be explicitly supported.'
        done
        CHECK_SERVICE=$SERVICE
    fi
    # Use the installed identity to recognize our existing listener correctly.
    sh "$CHECK_SERVICE/service.sh" check
fi
if [ "$ACTION" = install ]; then
    ensure_rw "$RESOURCES"
    space "$RESOURCES"
    if [ -e "$SERVICE" ]; then
        [ -d "$SERVICE" ] && [ ! -L "$SERVICE" ] || fail 'SSH service directory is invalid.'
        for F in service.sh sshd_config password.hash; do
            cmp -s "$BASE/ssh/$F" "$SERVICE/$F" || fail 'Existing SSH files differ. No files overwritten; updates must be explicitly supported.'
        done
    else
        mkdir -p "$(dirname "$SERVICE")"
        S="$SERVICE.new-$$"
        mkdir "$S"
        for F in service.sh sshd_config password.hash; do cp "$BASE/ssh/$F" "$S/$F"; done
        chmod 700 "$S/service.sh"
        chmod 600 "$S/sshd_config" "$S/password.hash"
        for F in service.sh sshd_config password.hash; do cmp -s "$BASE/ssh/$F" "$S/$F" || fail 'SSH package copy is incomplete.'; done
        sync
        mv "$S" "$SERVICE"
        sync
    fi
fi
MESSAGE='SSH task incomplete. Check the boot hook, state and individual reports.'
sh "$BASE/file-job.sh" "$BASE" "$USB" "$REPORT/boot-hook" "$ACTION" ssh "$SELECTED" || fail 'Could not update the SSH startup file.'
if [ "$ACTION" = preflight ]; then MESSAGE='SSH startup file checked; no service enabled.'; exit 0; fi
if [ -f "$BACKUP/state.txt" ] && line_is 'patch=ssh-bringback' "$BACKUP/state.txt"; then
    [ -f "$SERVICE/service.sh" ] || fail 'SSH startup hook is active, but service files are missing.'
    ensure_rw "$RESOURCES"
    printf 'enabled\n' > "$SERVICE/enabled"
    sync
    sh "$SERVICE/service.sh" boot "$USB" >/dev/null 2>&1 3>&- 4>&- &
    sleep 2
    sh "$SERVICE/service.sh" status || fail 'Boot hook installed, but SSH did not start. Check USB reports; Uninstall remains available.'
    MESSAGE='SSH installed: port 22, user cmu, password jci. Automatic startup configured; vehicle testing pending.'
else
    if [ -d "$SERVICE" ]; then
        ensure_rw "$RESOURCES"
        rm -f "$SERVICE/enabled"
        sync
        sh "$SERVICE/service.sh" stop || fail 'SSH startup hook removed, but the running service could not be fully stopped.'
    fi
    MESSAGE='SSH removed: original startup file restored, managed service stopped. Internal originals are preserved.'
fi
