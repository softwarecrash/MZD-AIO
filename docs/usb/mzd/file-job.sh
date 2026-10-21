#!/bin/sh
# Internal subprocess: one managed file, one journal and one cleanup scope.
set -eu
BASE=$1
USB=$2
REPORT=$3
ACTION=$4
MZD_TARGET_ID=$5
MZD_SELECTED_FILE=$6
export MZD_TARGET_ID MZD_SELECTED_FILE
mkdir -p "$REPORT"
fail() { echo "ABBRUCH: $*" >&2; exit 1; }
cleanup() { return 0; }
MESSAGE='Keine Aenderung vorgenommen. Details stehen im run.log.'
finish_job() {
    CODE=$?
    trap - 0
    set +e
    if ! cleanup; then CODE=1; MESSAGE='Abschluss fehlgeschlagen. Bitte run.log pruefen.'; fi
    printf '%s\n' "$MESSAGE" > "$REPORT/summary.txt"
    printf 'exit_code=%s\n' "$CODE" > "$REPORT/status.txt"
    printf '%s\n' "$MESSAGE"
    exit "$CODE"
}
trap finish_job 0
trap 'exit 130' INT
trap 'exit 143' TERM
. "$BASE/installer.sh"
