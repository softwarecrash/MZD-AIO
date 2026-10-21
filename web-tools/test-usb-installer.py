"""Offline integration tests. All device paths and mount commands are isolated."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import zipfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--zip', type=Path, required=True)
p.add_argument('--original', type=Path, required=True, help='Locally backed-up v74 List2Ctrl.js')
p.add_argument('--mainmenu-original', type=Path, required=True, help='Locally backed-up v74 MainMenuCtrl.js')
p.add_argument('--ssh-only', action='store_true', help='Run only SSH orchestration against existing manager fixtures')
p.add_argument('--list-loop-only', action='store_true', help='Test all List2 combinations and selective removal through the installer')
p.add_argument('--list-loop-fixtures', type=Path, help='Variant directory produced by test-list-loop.js')
p.add_argument('--bash', default='C:/Program Files/Git/bin/bash.exe')
args = p.parse_args()
root = Path(__file__).resolve().parents[1]
original = args.original.read_bytes()
menu_original = args.mainmenu_original.read_bytes()
assert hashlib.md5(menu_original).hexdigest() == '40ccb293b8c6f80960f0b953dd2e173e'
menu_patched = menu_original.replace(b'if (index < 0)\n    {\n        index = 0;', b'if (index < 0)\n    {\n        index = 4;').replace(b'if (index > 4)\n    {\n        index = 4;', b'if (index > 4)\n    {\n        index = 0;')
assert hashlib.md5(menu_patched).hexdigest() == 'ae272c9befc1350b93f23511568f13c7'
patched = original.replace(b"    this._beep('Long', 'Multicontroller');", b"//  this._beep('Long', 'Multicontroller');")
delay = original
for before, after in [(b'1Timeout :                1500,', b'1Timeout :                150,'),
                      (b'2Timeout :                5000,', b'2Timeout :                300,'),
                      (b'1Interval :               500,', b'1Interval :               200,'),
                      (b'2Interval :               1000,', b'2Interval :               300,')]:
    delay = delay.replace(before, after)
combined = delay.replace(b"    this._beep('Long', 'Multicontroller');", b"//  this._beep('Long', 'Multicontroller');")
assert hashlib.md5(original).hexdigest() == 'e111883b9dcbeb6bb154521826fcacac'
assert hashlib.md5(patched).hexdigest() == 'bb290d22840f82b1be14400ddb41f1b0'
with zipfile.ZipFile(args.zip) as z:
    assert z.testzip() is None
    manifest = json.loads(z.read('package-manifest.json'))
    assert manifest['mode'] == 'preflight'
    assert manifest['entry'] == 'mp3-console-keyboard'
    assert manifest['command'] == 'sh /mnt/sda1/tweaks.sh'
    assert len(z.namelist()) == 36
    for name, entry in manifest['assets'].items():
        data = z.read(name)
        assert data == (root / 'docs/usb' / name).read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry['sha256']
        assert len(data) == entry['bytes']
    for letter in 'abcd':
        assert ('../../../mnt/sd' + letter + '1/js/run.js').encode() in z.read('mp3/' + letter + '.mp3')

def bp(path):
    text = Path(path).resolve().as_posix()
    return '/' + text[0].lower() + text[2:] if len(text) > 1 and text[1] == ':' else text

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8', newline='\n')

checks = []
with tempfile.TemporaryDirectory(prefix='mzd-installer-') as temporary:
    temp = Path(temporary)
    cmu = temp / 'cmu'
    resources = temp / 'resources'
    resources.mkdir()
    target = cmu / 'jci/gui/common/controls/List2/js/List2Ctrl.js'
    target.parent.mkdir(parents=True)
    target.write_bytes(original)
    menu_target = cmu / 'jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js'
    menu_target.parent.mkdir(parents=True)
    menu_target.write_bytes(menu_original)
    ssh_stage = cmu / 'jci/scripts/stage_wifi.sh'
    write(ssh_stage, '#!/bin/sh\n\n')
    version = cmu / 'version.ini'
    good_version = 'JCI_SW_VER="MAZ_CMU-150_74.00.324"\nJCI_SW_VER_PATCH="A"\nJCI_SW_FLAVOR="cmu150_EU"\n'
    write(version, good_version)
    mounts, lock = temp / 'mounts', temp / 'installer.lock'
    mockbin = temp / 'bin'
    mockbin.mkdir()
    # rootfs + device on the same mountpoint matches the actual MCU inventory.
    write(mounts, f'rootfs {bp(cmu)} rootfs rw 0 0\n/dev/root {bp(cmu)} relfs ro,noatime 0 0\n/dev/res {bp(resources)} relfs ro 0 0\n')
    calls = temp / 'mount.calls'
    write(mockbin / 'mount', f'''#!/bin/sh
printf '%s %s %s\n' "$1" "$2" "$3" >> {shlex.quote(bp(calls))}
if [ -f {shlex.quote(bp(temp / 'fail-mount'))} ] && [ "$3" = {shlex.quote(bp(cmu))} ] && [ "$2" = remount,rw ]; then exit 1; fi
awk -v p="$3" -v opt="$2" '$2==p && $3!="rootfs" {{$4=(opt=="remount,rw"?"rw":"ro")}} {{print}}' {shlex.quote(bp(mounts))} > {shlex.quote(bp(temp / 'mounts.new'))}
mv {shlex.quote(bp(temp / 'mounts.new'))} {shlex.quote(bp(mounts))}
''')
    write(mockbin / 'df', '#!/bin/sh\nprintf "Filesystem 1024-blocks Used Available Capacity Mounted on\\nmock 999999 1 999998 1%% /\\n"\n')
    # No real disk flush/mount is needed for a synthetic fixture filesystem.
    write(mockbin / 'sync', '#!/bin/sh\nexit 0\n')
    write(mockbin / 'cp', '''#!/bin/sh
if [ "$1" = -p ]; then
    for dest in "$@"; do :; done
    case "$dest" in *"USB stick"*) echo 'Simulated FAT32: cannot preserve Unix metadata' >&2; exit 1 ;; esac
fi
exec /bin/cp "$@"
''')
    write(mockbin / 'mv', f'''#!/bin/sh
if [ -f {shlex.quote(bp(temp / 'fail-state'))} ] && [ "$1" = -f ]; then
    case "$3" in */state.txt) echo 'Simulated state write failure' >&2; exit 1 ;; esac
fi
/bin/mv "$@" || exit 1
if [ -f {shlex.quote(bp(temp / 'corrupt-commit'))} ] && [ "$1" = -f ]; then
    case "$2" in *.new) printf 'simulated corrupt write' > "$3" ;; esac
fi
''')
    for file in mockbin.iterdir(): file.chmod(0o700)
    backup = resources / 'aio-rework/backups/74.00.324A-EU/jci/gui/common/controls/List2/js/List2Ctrl.js.backup'
    def package(name):
        usb = temp / name
        shutil.copytree(root / 'docs/usb', usb)
        base = usb / 'mzd'
        # Change ONLY test copies: device reads, UID guard, PATH and mount table.
        main = (base / 'start.sh').read_text()
        main = main.replace('[ "$(id -u)" = 0 ]', ':').replace('/jci/version.ini', shlex.quote(bp(version)))
        main = main.replace('/proc/mounts', shlex.quote(bp(mounts)))
        main = main.replace('PATH=/usr/sbin:/usr/bin:/sbin:/bin', 'PATH=' + shlex.quote(bp(mockbin)) + ':/usr/bin:/bin')
        write(base / 'start.sh', main)
        dispatch = (base / 'dispatch.sh').read_text().replace('DISPATCH_LOCK=/tmp/mzd-aio-dispatch.lock', 'DISPATCH_LOCK=' + shlex.quote(bp(temp / 'dispatch.lock')))
        write(base / 'dispatch.sh', dispatch)
        worker = (base / 'common.sh').read_text()
        for before, after in [
            ('TARGET=/jci/gui/common/controls/List2/js/List2Ctrl.js', 'TARGET=' + shlex.quote(bp(target))),
            ('TARGET=/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js', 'TARGET=' + shlex.quote(bp(menu_target))),
            ('TARGET=/jci/scripts/stage_wifi.sh', 'TARGET=' + shlex.quote(bp(ssh_stage))),
            ('RESOURCES=/tmp/mnt/resources', 'RESOURCES=' + shlex.quote(bp(resources))),
            ('ROOT_MOUNT=/', 'ROOT_MOUNT=' + shlex.quote(bp(cmu))),
            ('MOUNTS=/proc/mounts', 'MOUNTS=' + shlex.quote(bp(mounts))),
            ('LOCK=/tmp/mzd-aio-rework.lock', 'LOCK=' + shlex.quote(bp(lock))),
        ]: worker = worker.replace(before, after)
        write(base / 'common.sh', worker)
        auxiliary = cmu / 'launcher.sh'
        write(auxiliary, 'original launcher\n')
        write(base / 'originals.md5', hashlib.md5(auxiliary.read_bytes()).hexdigest() + '  ' + bp(auxiliary) + '\n')
        write(base / 'selected.txt', 'list-beep\n')
        write(base / 'allowed.txt', 'list-beep\nshorter-delay\nlist-loop\nssh-bringback\nmain-menu-loop\nbackground\n')
        write(base / 'action.txt', 'preflight\n')
        return usb

    usb = package('USB stick A')
    def run(action, expected, text, *, stick=usb, answer='j\n', restore=False):
        write(stick / 'mzd/action.txt', action + '\n')
        before = set((stick / 'reports').glob('*'))
        script = stick / ('restore.sh' if restore else 'tweaks.sh')
        result = subprocess.run([args.bash, '--noprofile', '--norc', str(script)], cwd=temp, input=answer.encode(), capture_output=True)
        result.stdout = result.stdout.decode(errors='replace')
        result.stderr = result.stderr.decode(errors='replace')
        assert result.returncode == expected, result.stdout + result.stderr
        assert text in result.stdout + result.stderr, result.stdout + result.stderr
        created = set((stick / 'reports').glob('*')) - before
        assert len(created) == 1
        report = created.pop()
        assert text in (report / 'run.log').read_text() or text in (report / 'summary.txt').read_text()
        assert (report / 'status.txt').read_text().strip() == 'exit_code=' + str(expected)
        assert ' relfs rw ' not in mounts.read_text(), mounts.read_text()
        assert ' vfat rw ' not in mounts.read_text(), mounts.read_text()
        checks.append(text)
        return report

    if args.list_loop_only:
        assert args.list_loop_fixtures, '--list-loop-fixtures is required'
        variants = [(args.list_loop_fixtures / f'{mask}.js').read_bytes() for mask in range(8)]
        verification = json.loads((args.list_loop_fixtures / 'verification.json').read_text())
        for mask, data in enumerate(variants):
            assert hashlib.sha256(data).hexdigest() == verification['hashes'][str(mask)]
        assert variants[0] == original and variants[1] == patched and variants[2] == delay and variants[3] == combined
        names = ['list-beep', 'shorter-delay', 'list-loop']
        write(usb / 'mzd/selected.txt', 'list-loop\n')
        run('preflight', 0, 'Pruefung abgeschlossen')
        assert target.read_bytes() == original and not backup.exists()
        new_usb = package('USB stick B')
        (new_usb / 'mzd/selected.txt').unlink()
        (new_usb / 'mzd/allowed.txt').unlink()
        current, backup_time, old_state = 0, None, None
        steps = [3, 7, 3, 2, 6, 7, 5, 4, 0, 1, 5, 0]
        for step, wanted in enumerate(steps):
            if step == len(steps) - 1:
                run('restore', 0, 'Original erfolgreich wiederhergestellt', stick=new_usb, restore=True)
            else:
                changed = current ^ wanted
                chosen = [name for bit, name in enumerate(names) if changed & (1 << bit)]
                write(usb / 'mzd/selected.txt', '\n'.join(chosen) + '\n')
                action = 'install' if wanted & ~current else 'uninstall'
                run(action, 0, 'Erfolgreich installiert' if action == 'install' else 'Ausgewaehlte Patches entfernt')
            assert target.read_bytes() == variants[wanted], (current, wanted)
            assert (backup / 'original').read_bytes() == original
            stamp = (backup / 'original').stat().st_mtime_ns
            if backup_time is None: backup_time = stamp
            assert stamp == backup_time
            state = (backup / 'state.txt').read_text()
            assert state.splitlines()[2:] == ['patch=' + name for bit, name in enumerate(names) if wanted & (1 << bit)]
            if step == 0: old_state = state
            if step == 2: assert state == old_state  # Adding/removing loop preserves old beep+delay state exactly.
            current = wanted
        assert (new_usb / 'backups/74.00.324A-EU/jci/gui/common/controls/List2/js/List2Ctrl.js.backup/original').read_bytes() == original
        target.write_bytes(original + b'// foreign change\n')
        write(usb / 'mzd/selected.txt', 'list-loop\n')
        run('install', 1, 'ausserhalb des Installers geaendert')
        assert target.read_bytes() == original + b'// foreign change\n'
        print('Passed', len(checks), 'list-loop installer runs: all eight states, selective removal, existing beep/delay state, immutable originals, new-stick restore and foreign-change rejection.')
        raise SystemExit(0)

    if not args.ssh_only:
        run('preflight', 0, 'Pruefung abgeschlossen')
        assert not backup.exists()
        run('install', 0, 'Abgebrochen', answer='n\n')
        assert target.read_bytes() == original and not backup.exists()
        run('install', 0, 'Erfolgreich installiert')
        assert target.read_bytes() == patched
        assert (backup / 'original').read_bytes() == original
        usb_backup = usb / 'backups/74.00.324A-EU/jci/gui/common/controls/List2/js/List2Ctrl.js.backup/original'
        assert usb_backup.read_bytes() == original
        mtime = (backup / 'original').stat().st_mtime_ns
        run('install', 0, 'bereits vorhanden')
        assert (backup / 'original').stat().st_mtime_ns == mtime
        new_usb = package('USB stick B')
        (new_usb / 'mzd/selected.txt').unlink()
        (new_usb / 'mzd/allowed.txt').unlink()
        run('nonsense ignored', 0, 'Original erfolgreich wiederhergestellt', stick=new_usb, restore=True)
        assert target.read_bytes() == original
        assert (new_usb / 'backups/74.00.324A-EU/jci/gui/common/controls/List2/js/List2Ctrl.js.backup/original').read_bytes() == original
        run('restore', 0, 'bereits vorhanden', stick=new_usb, restore=True)
        run('install', 0, 'Erfolgreich installiert')
        run('uninstall', 0, 'Ausgewaehlte Patches entfernt')
        assert target.read_bytes() == original
        write(usb / 'mzd/selected.txt', 'shorter-delay\n')
        run('install', 0, 'Erfolgreich installiert')
        assert target.read_bytes() == delay
        write(usb / 'mzd/selected.txt', 'list-beep\n')
        run('install', 0, 'Erfolgreich installiert')
        assert target.read_bytes() == combined
        run('uninstall', 0, 'Ausgewaehlte Patches entfernt')
        assert target.read_bytes() == delay
        assert 'patch=shorter-delay' in (backup / 'state.txt').read_text()
        write(usb / 'mzd/selected.txt', 'list-beep\nshorter-delay\n')
        run('install', 0, 'Erfolgreich installiert')
        assert target.read_bytes() == combined
        write(usb / 'mzd/selected.txt', 'shorter-delay\n')
        run('uninstall', 0, 'Ausgewaehlte Patches entfernt')
        assert target.read_bytes() == patched
        assert (backup / 'original').stat().st_mtime_ns == mtime
        run('restore', 0, 'Original erfolgreich wiederhergestellt', stick=new_usb, restore=True)
        assert target.read_bytes() == original
        # The file commit may succeed while its state publication is interrupted.
        write(usb / 'mzd/selected.txt', 'shorter-delay\n')
        write(temp / 'fail-state', 'interrupt publication')
        run('install', 1, 'Zustand konnte nicht gespeichert werden')
        assert target.read_bytes() == delay and (backup / 'transaction').is_dir()
        (temp / 'fail-state').unlink()
        run('preflight', 1, 'Unterbrochener Vorgang erkannt')
        run('install', 0, 'bereits vorhanden')
        assert target.read_bytes() == delay and not (backup / 'transaction').exists()
        run('restore', 0, 'Original erfolgreich wiederhergestellt', stick=new_usb, restore=True)
        write(usb / 'mzd/selected.txt', 'list-beep\n')
        (backup / 'original').write_bytes(b'corrupt backup')
        run('install', 1, 'ist beschaedigt')
        assert target.read_bytes() == original
        assert (backup / 'original').read_bytes() == b'corrupt backup'
        (backup / 'original').write_bytes(original)
        target.write_bytes(b'unknown system state')
        run('install', 1, 'ausserhalb des Installers geaendert')
        assert target.read_bytes() == b'unknown system state'
        target.write_bytes(original)
        # A USB initially mounted ro must also return to ro after its log is written.
        ro_usb = package('USB-C')
        physical = subprocess.run([args.bash, '-c', 'cd ' + shlex.quote(bp(ro_usb)) + ' && pwd -P'], capture_output=True, text=True, check=True).stdout.strip()
        write(mounts, mounts.read_text() + f'/dev/usb {physical} vfat ro 0 0\n')
        run('preflight', 0, 'Pruefung abgeschlossen', stick=ro_usb)
        write(version, good_version.replace('74.00.324', '70.00.100'))
        run('preflight', 1, 'Nicht Firmware')
        write(version, good_version.replace('PATCH="A"', 'PATCH="B"'))
        run('preflight', 1, 'Nicht Patchstand')
        write(version, good_version.replace('cmu150_EU', 'cmu150_NA'))
        run('preflight', 1, 'Nicht Region')
        write(version, good_version)
        write(usb / 'mzd/selected.txt', '$(touch bad)\n')
        run('install', 1, 'Ungueltige Tweak-ID')
        write(usb / 'mzd/selected.txt', 'background\n')
        run('install', 1, 'noch nicht portiert')
        write(usb / 'mzd/selected.txt', 'list-beep\n')
        lock.mkdir()
        run('install', 1, 'anderer Installer')
        assert lock.exists()
        lock.rmdir()
        good_sed = (usb / 'mzd/patches/list-beep.sed').read_bytes()
        write(usb / 'mzd/patches/list-beep.sed', 's/does-not-exist/unchanged/\n')
        run('install', 1, 'Patchdefinition passt nicht')
        assert target.read_bytes() == original
        assert not list(target.parent.glob('.mzd-aio-*'))
        (usb / 'mzd/patches/list-beep.sed').write_bytes(good_sed)
        write(temp / 'fail-mount', 'fail')
        run('install', 1, 'Partition nicht beschreibbar')
        assert target.read_bytes() == original
        (temp / 'fail-mount').unlink()
        write(temp / 'corrupt-commit', 'inject post-commit corruption')
        run('install', 1, 'Vorheriger Dateistand wurde wiederhergestellt')
        assert target.read_bytes() == original
        (temp / 'corrupt-commit').unlink()
    else:
        backup.mkdir(parents=True)
        (backup / 'original').write_bytes(original)
        write(backup / 'metadata.txt', 'firmware=74.00.324A-EU\ntarget=/jci/gui/common/controls/List2/js/List2Ctrl.js\nmd5=e111883b9dcbeb6bb154521826fcacac\n')
        write(backup / 'state.txt', 'format=1\nmd5=e111883b9dcbeb6bb154521826fcacac\n')
        new_usb = package('USB stick B')
        (new_usb / 'mzd/selected.txt').unlink()
        (new_usb / 'mzd/allowed.txt').unlink()
    # Main-menu boundaries are a separate managed file, not a List2 replacement.
    menu_backup = resources / 'aio-rework/backups/74.00.324A-EU/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js.backup'
    write(usb / 'mzd/selected.txt', 'main-menu-loop\n')
    run('preflight', 0, 'Pruefung abgeschlossen')
    assert menu_target.read_bytes() == menu_original and not menu_backup.exists()
    run('install', 0, 'Erfolgreich installiert')
    assert menu_target.read_bytes() == menu_patched and target.read_bytes() == original
    assert (menu_backup / 'original').read_bytes() == menu_original
    assert (usb / 'backups/74.00.324A-EU/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js.backup/original').read_bytes() == menu_original
    menu_time = (menu_backup / 'original').stat().st_mtime_ns
    run('install', 0, 'bereits vorhanden')
    assert (menu_backup / 'original').stat().st_mtime_ns == menu_time
    write(usb / 'mzd/selected.txt', 'main-menu-loop\nlist-beep\nshorter-delay\n')
    run('install', 0, 'Erfolgreich installiert')
    assert menu_target.read_bytes() == menu_patched and target.read_bytes() == combined
    write(usb / 'mzd/selected.txt', 'main-menu-loop\n')
    run('uninstall', 0, 'Ausgewaehlte Patches entfernt')
    assert menu_target.read_bytes() == menu_original and target.read_bytes() == combined
    run('install', 0, 'Erfolgreich installiert')
    run('restore', 0, 'Original erfolgreich wiederhergestellt', stick=new_usb, restore=True)
    assert menu_target.read_bytes() == menu_original and target.read_bytes() == original
    menu_target.write_bytes(menu_original + b'// foreign change\n')
    run('install', 1, 'ausserhalb des Installers geaendert')
    assert menu_target.read_bytes() == menu_original + b'// foreign change\n'
    menu_target.write_bytes(menu_original)
    # Controller integration uses a fake service; the real supervisor has its
    # own test suite with fake kernel/sshd commands, never a real listener.
    ssh_fault = temp / 'ssh-port-busy'
    write(usb / 'mzd/ssh/service.sh', f'''#!/bin/sh
D=$(CDPATH= cd "$(dirname "$0")" && pwd)
case "$1" in
check) printf '%s\n' "$D" >> {shlex.quote(bp(temp / "ssh-check-sources"))}; if [ -f {shlex.quote(bp(ssh_fault))} ]; then echo 'Port 22 ist bereits belegt'; exit 1; fi ;;
boot) [ -f "$D/enabled" ] && printf running > "$D/test-running" ;;
status) [ -f "$D/test-running" ] || exit 1; echo 'SSH laeuft: Port 22, Benutzer cmu.' ;;
stop) rm -f "$D/test-running"; echo 'SSH beendet' ;;
*) exit 1 ;;
esac
''')
    service_dir = resources / 'aio-rework/services/ssh'
    ssh_backup = resources / 'aio-rework/backups/74.00.324A-EU/jci/scripts/stage_wifi.sh.backup'
    write(usb / 'mzd/selected.txt', 'ssh-bringback\n')
    write(ssh_fault, 'busy')
    run('install', 1, 'Port 22 ist bereits belegt')
    assert ssh_stage.read_bytes() == b'#!/bin/sh\n\n' and not service_dir.exists()
    ssh_fault.unlink()
    target.write_bytes(b'broken GUI file must not block independent SSH install')
    run('install', 0, 'SSH installiert')
    assert target.read_bytes() == b'broken GUI file must not block independent SSH install'
    assert b'service.sh boot' in ssh_stage.read_bytes()
    assert (service_dir / 'enabled').exists()
    ssh_original_time = (ssh_backup / 'original').stat().st_mtime_ns
    run('install', 0, 'SSH installiert')
    assert (ssh_backup / 'original').stat().st_mtime_ns == ssh_original_time
    assert (temp / 'ssh-check-sources').read_text().splitlines()[-1].endswith('/aio-rework/services/ssh')
    run('uninstall', 0, 'SSH entfernt')
    assert ssh_stage.read_bytes() == b'#!/bin/sh\n\n'
    assert not (service_dir / 'enabled').exists()
    target.write_bytes(original)
    write(usb / 'mzd/selected.txt', 'list-beep\nssh-bringback\n')
    run('install', 0, 'SSH installiert')
    assert target.read_bytes() == patched and (service_dir / 'enabled').exists()
    write(usb / 'mzd/selected.txt', 'list-beep\n')
    run('uninstall', 0, 'Ausgewaehlte Patches entfernt')
    assert target.read_bytes() == original and (service_dir / 'enabled').exists()
    run('restore', 0, 'SSH entfernt', stick=new_usb, restore=True)
    assert target.read_bytes() == original and ssh_stage.read_bytes() == b'#!/bin/sh\n\n'
    assert not (service_dir / 'enabled').exists() and not (service_dir / 'test-running').exists()
    (backup / 'original').unlink()
    (backup / 'metadata.txt').unlink()
    (backup / 'state.txt').unlink()
    backup.rmdir()
    target.write_bytes(patched)
    run('uninstall', 1, 'Originalsicherung fehlt')
    assert target.read_bytes() == patched
    target.write_bytes(original)
    # No writable report directory: fail before any target/backup work.
    (usb / 'reports').rename(usb / 'saved-reports')
    write(usb / 'reports', 'blocked')
    result = subprocess.run([args.bash, str(usb / 'tweaks.sh')], capture_output=True, text=True)
    assert result.returncode == 1 and 'Kein interner Ersatzspeicher' in result.stderr
    assert target.read_bytes() == original
    assert not backup.exists()
print('Passed', len(checks), 'isolated runs: install/uninstall/new-stick full restore, immutable backups, early logs, original hashes, write preparation/mount failures, firmware gates, locks and source-relative paths.')
