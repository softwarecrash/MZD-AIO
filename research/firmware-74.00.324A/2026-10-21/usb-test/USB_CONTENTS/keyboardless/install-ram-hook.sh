#!/bin/sh
# ONE-TIME MANUAL PREPARATION. This script is NOT executed by merely inserting USB.
set -eu
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
D=/tmp/mzd-keyboardless-test
TARGET=/jci/scripts/startSystemScripts.sh
BASE=$(CDPATH= cd "$(dirname "$0")" && pwd)
fail() { echo "ERROR: $*" >&2; exit 1; }
[ "$(id -u)" = 0 ] || fail 'Root shell required'
[ ! -e "$D" ] || fail "$D already exists; inspect logs or remove the old hook first"
grep -q 'JCI_SW_VER="MAZ_CMU-150_74.00.324"' /jci/version.ini || fail 'Unexpected firmware'
for tool in mount umount cp chmod md5sum awk; do command -v "$tool" >/dev/null || fail "Missing tool: $tool"; done
ACTUAL=$(md5sum "$TARGET" | awk '{print $1}')
[ "$ACTUAL" = f0722945ea92d785dad1a15b2f094e61 ] || fail 'Original diagnostic script does not match the backed-up file'
for file in diagnostic-hook.sh launch-terminal.sh terminal-entry.sh start-ssh-test.sh mazda.pub uninstall-ram-hook.sh; do
    [ -s "$BASE/$file" ] || fail "Missing package file: $file"
done
umask 077
mkdir "$D"
cp "$TARGET" "$D/startSystemScripts.original.sh"
for file in diagnostic-hook.sh launch-terminal.sh terminal-entry.sh start-ssh-test.sh mazda.pub uninstall-ram-hook.sh; do
    cp "$BASE/$file" "$D/$file"
done
chmod 700 "$D/"*.sh
chmod 600 "$D/mazda.pub"
mount -o bind "$D/diagnostic-hook.sh" "$TARGET"
if ! awk -v p="$TARGET" '$2==p {f=1} END {exit !f}' /proc/mounts; then
    umount "$TARGET" 2>/dev/null || :
    fail 'Bind mount could not be confirmed'
fi
echo 'RAM hook installed. OEM flash files were not overwritten.'
echo 'Select another MP3 and return to a trigger track to load js/run.js.'
echo 'Then test a NEW SSH connection on port 2223.'
echo 'The hook disappears on MCU reboot.'
echo "Undo: sh $D/uninstall-ram-hook.sh"
