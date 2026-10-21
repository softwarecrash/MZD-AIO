"""Compare actual package/patch results with independent owner/OEM/AIO references."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shlex
import subprocess
import tarfile
import tempfile
import zipfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--zip', type=Path, required=True)
p.add_argument('--variants', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--bash', default='C:/Program Files/Git/bin/bash.exe')
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
firmware = root.parent / 'patch_audit_work/jci'
aio = root.parent / 'aio_reference/app/files/tweaks'
archive = root.parent / 'usb_keyboardless_test/original_usb.tar.gz'
sha = lambda data: hashlib.sha256(data).hexdigest()
reference = json.loads((root / 'docs/mp3-reference.json').read_text('utf-8'))
assert sha(archive.read_bytes()) == reference['archive_sha256']
with tarfile.open(archive) as source, zipfile.ZipFile(a.zip) as z:
    assert z.testzip() is None
    for name, expected in reference['files'].items():
        data = source.extractfile(name).read()
        assert sha(data) == expected['sha256'] and len(data) == expected['bytes']
        assert z.read(name) == data == (root / 'docs/usb' / name).read_bytes(), name
    for letter in 'abcd':
        assert f'../../../mnt/sd{letter}1/js/run.js'.encode() in z.read(f'mp3/{letter}.mp3')
    run = z.read('js/run.js').decode('utf-8')
    for name in re.findall(r"mnt/sd[a-d]1/([^'\"]+)", run):
        assert name in z.namelist(), name
    for name in re.findall(r'(?:src|href)="\./([^"]+)"', z.read('dev.html').decode()):
        assert name in z.namelist(), name
    assert 'mazda.pub' not in z.namelist() and 'start-ssh.sh' not in z.namelist()
    manifest = json.loads(z.read('package-manifest.json'))
    for name, expected in manifest['assets'].items():
        assert sha(z.read(name)) == expected['sha256']

original = (firmware / 'gui/common/controls/List2/js/List2Ctrl.js').read_text('utf-8')
old_loop_path = aio / 'config/list-loop/jci/gui/common/controls/List2/js/List2Ctrl.js'
old_loop = old_loop_path.read_text('utf-8')
names = ['_handleMCCW', '_handleMCCCW', '_handleMCDown', '_handleMCUp']
def method(source, name, cls='List2Ctrl'):
    return re.search(rf'{cls}\.prototype\.{name} = function\([^\n]*\)\n.*?^}};', source, re.S | re.M).group()

# Derive the four numerical substitutions from the original AIO shell snippet.
delay_script = (aio / '07_shorterdelay-i.txt').read_text('utf-8')
delay_pairs = re.findall(r"sed -i 's/([^/]+)/([^/]+)/g'", delay_script)
assert len(delay_pairs) == 4
assert (root / 'docs/usb/mzd/patches/shorter-delay.sed').read_text('utf-8').splitlines() == [f's/{x}/{y}/g' for x, y in delay_pairs]
beep_source = (aio / '07_listbeep-i.txt').read_text('utf-8')
beep_sed = (root / 'docs/usb/mzd/patches/list-beep.sed').read_text('utf-8').strip()
assert beep_sed in beep_source
variant_hashes = {}
for mask in range(8):
    expected = original
    if mask & 1:
        expected = expected.replace("    this._beep('Long', 'Multicontroller');", "//  this._beep('Long', 'Multicontroller');")
    if mask & 2:
        for before, after in delay_pairs:
            assert expected.count(before) == 1
            expected = expected.replace(before, after)
    if mask & 4:
        for name in names:
            expected = expected.replace(method(expected, name), method(old_loop, name))
    actual = (a.variants / f'{mask}.js').read_bytes()
    assert actual == expected.encode('utf-8'), mask
    assert re.findall(r'List2Ctrl\.prototype\.([\w]+)\s*=', actual.decode()) == re.findall(r'List2Ctrl\.prototype\.([\w]+)\s*=', original)
    variant_hashes[mask] = sha(actual)

menu_path = firmware / 'gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js'
menu_original = menu_path.read_bytes()
menu_expected = menu_original.replace(b'if (index < 0)\n    {\n        index = 0;', b'if (index < 0)\n    {\n        index = 4;').replace(b'if (index > 4)\n    {\n        index = 4;', b'if (index > 4)\n    {\n        index = 0;')
def bp(value):
    text = Path(value).resolve().as_posix()
    return '/' + text[0].lower() + text[2:] if len(text) > 1 and text[1] == ':' else text
with tempfile.TemporaryDirectory(prefix='mzd-port-audit-') as temp:
    output = Path(temp) / 'MainMenuCtrl.js'
    subprocess.run([a.bash, bp(root / 'docs/usb/mzd/patches/main-menu-loop.sh'), 'apply', bp(menu_path), bp(output)], check=True)
    assert output.read_bytes() == menu_expected
    legacy_menu = (aio / 'config/main-menu-loop/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js').read_text('utf-8')
    assert method(menu_expected.decode(), '_offsetFocus', 'MainMenuCtrl') == method(legacy_menu, '_offsetFocus', 'MainMenuCtrl')

report = {
    'status': 'offline_original_comparison_passed_download_still_blocked',
    'mp3_reference_files': list(reference['files']),
    'mp3_archive_sha256': reference['archive_sha256'],
    'list2_all_eight_variants_match_original_aio_changes_only': True,
    'list2_added_prototype_methods': [],
    'list2_variant_sha256': variant_hashes,
    'mainmenu_exactly_two_original_aio_boundary_changes': True,
    'mainmenu_sha256': sha(menu_expected),
    'delay_marker_note': 'Original informational Shorter Delay Mod comment omitted; state is managed separately. No additional executable behavior.',
    'ssh': 'Explicitly permitted own implementation retained, not represented as original AIO port. Hardware login/boot not tested; CMU unreachable.',
    'open_release_items': ['Real SSH device test', 'Safe rollback of previously published rejected custom list-loop variants'],
    'sources': {str(x.relative_to(aio)): sha(x.read_bytes()) for x in [old_loop_path, aio / '07_shorterdelay-i.txt', aio / '07_listbeep-i.txt', aio / 'config/main-menu-loop/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js']}
}
a.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
print('Passed independent archive/ZIP dependency audit, all eight List2 variants, unchanged prototype set and exact MainMenu AIO boundaries.')
