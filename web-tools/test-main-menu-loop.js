/* Offline behavior check against a locally backed-up OEM MainMenuCtrl.js. */
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const { execFile } = require('node:child_process');
const { promisify } = require('node:util');
const { createHash } = require('node:crypto');

module.exports = async function test(originalPath) {
  const root = path.resolve(__dirname, '..');
  const original = await fs.readFile(originalPath, 'utf8');
  const temp = await fs.mkdtemp(path.join(os.tmpdir(), 'mzd-mainmenu-'));
  const output = path.join(temp, 'MainMenuCtrl.js');
  const bp = value => path.resolve(value).replace(/\\/g, '/').replace(/^([A-Za-z]):/, (_, drive) => '/' + drive.toLowerCase());
  try {
    await promisify(execFile)('C:/Program Files/Git/bin/bash.exe', [
      bp(path.join(root, 'docs/usb/mzd/patches/main-menu-loop.sh')), 'apply', bp(originalPath), bp(output)
    ]);
    const patched = await fs.readFile(output, 'utf8');
    assert.equal(createHash('md5').update(patched).digest('hex'), 'ae272c9befc1350b93f23511568f13c7');
    const before = original.split('\n'), after = patched.split('\n');
    assert.equal(before.length, after.length);
    assert.deepEqual(before.flatMap((line, i) => line === after[i] ? [] : [[line.trim(), after[i].trim()]]), [
      ['index = 0;', 'index = 4;'], ['index = 4;', 'index = 0;']
    ]);
    for (const [source, wraps] of [[original, false], [patched, true]]) {
      const context = { log: { addSrcFile() {} }, framework: { registerCtrlLoaded() {} } };
      vm.runInNewContext(source, context);
      const offset = context.MainMenuCtrl.prototype._offsetFocus;
      for (let position = 0; position < 5; position++) {
        for (const direction of [-1, 1]) {
          const expected = wraps ? (position + direction + 5) % 5 : Math.max(0, Math.min(4, position + direction));
          const control = { focus: position, highlight: position, _getFocus() { return this.focus; },
            _setFocus(value) { this.focus = value; }, _setHighlight(value) { this.highlight = value; } };
          offset.call(control, direction);
          assert.equal(control.focus, expected);
          assert.equal(control.highlight, expected);
        }
      }
    }
    return { passed: true, checks: '20 OEM/patched focus cases, wrap both directions, interior movement, exactly two changed lines' };
  } finally {
    await fs.rm(temp, { recursive: true, force: true });
  }
};
if (require.main === module) module.exports(process.argv[2]).then(console.log).catch(error => { console.error(error); process.exitCode = 1; });
