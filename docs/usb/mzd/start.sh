#!/bin/sh
# Keyboard entry point: sh /mnt/sda1/mzd/start.sh
# Preflight only: no remounts, OEM writes, watchdog changes or SSH setup.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
umask 077
BASE=$(CDPATH= cd "$(dirname "$0")" && pwd)
USB=$(CDPATH= cd "$BASE/.." && pwd)
fail() { echo "ABBRUCH: $*" >&2; exit 1; }
[ "$(id -u)" = 0 ] || fail 'Root-Konsole erforderlich.'
for tool in grep md5sum date mkdir cat; do command -v "$tool" >/dev/null || fail "Werkzeug fehlt: $tool"; done
[ -r "$BASE/selected.txt" ] || fail 'Auswahldatei fehlt.'
[ -r "$BASE/originals.md5" ] || fail 'Original-Pruefsummen fehlen.'
grep -qx 'JCI_SW_VER="MAZ_CMU-150_74.00.324"' /jci/version.ini || fail 'Nicht Firmware 74.00.324.'
grep -qx 'JCI_SW_VER_PATCH="A"' /jci/version.ini || fail 'Nicht Patchstand A.'
grep -qx 'JCI_SW_FLAVOR="cmu150_EU"' /jci/version.ini || fail 'Nicht Region EU.'
# The generated catalog is data, never sourced or evaluated as shell code.
while IFS= read -r patch || [ -n "$patch" ]; do
    [ -n "$patch" ] || continue
    case "$patch" in -*|*[!a-z0-9-]*) fail 'Ungueltige Tweak-ID.' ;; esac
    grep -qxF "$patch" "$BASE/allowed.txt" || fail "Unbekannte Auswahl: $patch"
done < "$BASE/selected.txt"
STAMP=$(date +%Y%m%d-%H%M%S)
REPORT="$USB/reports/$STAMP-$$"
mkdir -p "$REPORT" || fail 'USB-Stick ist nicht beschreibbar.'
RESULT=0
{
    echo 'MZD-AIO WEB / V74 VORPRUEFUNG'
    echo 'firmware=74.00.324A region=EU'
    echo 'mode=preflight installable=false'
    echo 'Keine Patches installiert. Keine Originaldateien veraendert.'
    echo 'Ausgewaehlte Tweaks:'
    cat "$BASE/selected.txt"
    echo 'OEM-Dateivergleich:'
    if md5sum -c "$BASE/originals.md5"; then
        echo 'originals=match'
    else
        echo 'originals=mismatch'
        echo 'Dateistand weicht ab. Vor einer spaeteren Installation neu pruefen.'
        RESULT=2
    fi
} > "$REPORT/preflight.txt" 2>&1
cat "$REPORT/preflight.txt"
echo "Bericht: $REPORT/preflight.txt"
exit "$RESULT"
