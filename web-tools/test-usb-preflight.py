"""Isolated shell/ZIP tests. Never invoke the production script against a device."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--zip', type=Path, required=True)
p.add_argument('--bash', default='C:/Program Files/Git/bin/bash.exe')
args = p.parse_args()
root = Path(__file__).resolve().parents[1]

with zipfile.ZipFile(args.zip) as z:
    assert z.testzip() is None
    manifest = json.loads(z.read('package-manifest.json'))
    assert manifest['installable'] is False
    assert manifest['entry'] == 'mp3-console-keyboard'
    assert len(z.namelist()) == 13
    for name, entry in manifest['assets'].items():
        data = z.read(name)
        assert data == (root / 'docs/usb' / name).read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry['sha256']
        assert len(data) == entry['bytes']
    for index, name in enumerate('abcd'):
        assert ('../../../mnt/sd' + name + '1/js/run.js').encode() in z.read('mp3/' + name + '.mp3')
    assert json.loads(z.read('project.json'))['name'] == 'Test \u00e4'
    assert not any('ssh' in name or name.endswith(('.pub', '.pem')) for name in z.namelist())

def bash_path(path):
    text = Path(path).resolve().as_posix()
    return '/' + text[0].lower() + text[2:] if len(text) > 1 and text[1] == ':' else text

source = (root / 'docs/usb/mzd/start.sh').read_text(encoding='utf-8')
with tempfile.TemporaryDirectory(prefix='mzd-preflight-') as temporary:
    temp = Path(temporary)
    package = temp / 'usb stick/mzd'
    package.mkdir(parents=True)
    fixture = temp / 'List2Ctrl.js'
    fixture.write_bytes(b'ORIGINAL FIXTURE\n')
    firmware = temp / 'version.ini'
    expected_version = 'JCI_SW_VER="MAZ_CMU-150_74.00.324"\nJCI_SW_VER_PATCH="A"\nJCI_SW_FLAVOR="cmu150_EU"\n'
    firmware.write_text(expected_version, encoding='utf-8', newline='\n')
    (package / 'originals.md5').write_text(hashlib.md5(fixture.read_bytes()).hexdigest() + '  ' + bash_path(fixture) + '\n', encoding='utf-8', newline='\n')
    (package / 'allowed.txt').write_text('list-beep\n', encoding='utf-8', newline='\n')
    (package / 'selected.txt').write_text('list-beep\n', encoding='utf-8', newline='\n')
    # Only the TEST COPY bypasses host UID; all absolute device reads are replaced.
    script = source.replace('[ "$(id -u)" = 0 ]', ':').replace('/jci/version.ini', bash_path(firmware))
    (package / 'start.sh').write_text(script, encoding='utf-8', newline='\n')
    def run(expected, text):
        before = set((package.parent / 'reports').glob('*'))
        result = subprocess.run([args.bash, '--noprofile', '--norc', str(package / 'start.sh')], cwd=temp, capture_output=True, text=True)
        assert result.returncode == expected, result.stdout + result.stderr
        assert text in result.stdout + result.stderr, result.stdout + result.stderr
        created = set((package.parent / 'reports').glob('*')) - before
        assert len(created) == 1
        report = created.pop()
        assert text in (report / 'run.log').read_text()
        assert (report / 'status.txt').read_text().strip() == 'exit_code=' + str(expected)
    run(0, 'originals=match')
    assert fixture.read_bytes() == b'ORIGINAL FIXTURE\n'
    fixture.write_bytes(b'UNKNOWN FILE STATE\n')
    run(2, 'originals=mismatch')
    assert fixture.read_bytes() == b'UNKNOWN FILE STATE\n'
    firmware.write_text(expected_version.replace('74.00.324', '70.00.100'), encoding='utf-8', newline='\n')
    run(1, 'Nicht Firmware')
    firmware.write_text(expected_version.replace('PATCH="A"', 'PATCH="B"'), encoding='utf-8', newline='\n')
    run(1, 'Nicht Patchstand A')
    firmware.write_text(expected_version.replace('cmu150_EU', 'cmu150_NA'), encoding='utf-8', newline='\n')
    run(1, 'Nicht Region EU')
    firmware.write_text(expected_version, encoding='utf-8', newline='\n')
    (package / 'selected.txt').write_text('unknown\n', encoding='utf-8', newline='\n')
    run(1, 'Unbekannte Auswahl')
    (package / 'selected.txt').write_text('$(touch bad)\n', encoding='utf-8', newline='\n')
    run(1, 'Ungueltige Tweak-ID')
    assert not (package / 'bad').exists()
    (package / 'selected.txt').unlink()
    run(1, 'Auswahldatei fehlt')
    assert list((package.parent / 'reports').glob('*/preflight.txt'))
    # An unavailable report destination must stop without an internal fallback.
    (package.parent / 'reports').rename(package.parent / 'saved-reports')
    (package.parent / 'reports').write_text('blocked')
    result = subprocess.run([args.bash, str(package / 'start.sh')], cwd=temp, capture_output=True, text=True)
    assert result.returncode == 1
    assert 'Kein interner Ersatzspeicher' in result.stdout + result.stderr
print('Passed: ZIP/MP3 integrity, firmware gates, early-error USB logs, exit codes, source-relative report paths (spaces and different cwd), unavailable storage and unchanged fixtures.')
