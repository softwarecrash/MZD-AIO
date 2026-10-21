/* Requires a local OEM List2Ctrl.js. No files from the CMU are published. */
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const { execFile } = require('node:child_process');
const { promisify } = require('node:util');
const { createHash } = require('node:crypto');

module.exports = async function test(originalPath) {
  const root = path.resolve(__dirname, '..'), dir = await fs.mkdtemp(path.join(os.tmpdir(), 'mzd-list-loop-'));
  const bp = value => path.resolve(value).replace(/\\/g, '/').replace(/^([A-Za-z]):/, (_, drive) => '/' + drive.toLowerCase());
  const patches = ['list-beep', 'shorter-delay', 'list-loop'], variants = [], hashes = {};
  for (let mask = 0; mask < 8; mask++) {
    let input = originalPath;
    for (let bit = 0; bit < 3; bit++) {
      if (!(mask & (1 << bit))) continue;
      const output = path.join(dir, 'work-' + mask + '-' + bit + '.js');
      await promisify(execFile)('C:/Program Files/Git/bin/bash.exe', [
        bp(path.join(root, 'docs/usb/mzd/patches', patches[bit] + '.sh')), 'apply', bp(input), bp(output)
      ]);
      input = output;
    }
    const source = await fs.readFile(input, 'utf8');
    variants.push(source);
    await fs.writeFile(path.join(dir, mask + '.js'), source);
    hashes[mask] = createHash('sha256').update(source).digest('hex');
  }
  const legacy = await fs.readFile(path.join(root, '../aio_reference/app/files/tweaks/config/list-loop/jci/gui/common/controls/List2/js/List2Ctrl.js'), 'utf8');
  const legacyContext = { window: {}, log: { addSrcFile() {} }, framework: { registerCtrlLoaded() {} } };
  vm.runInNewContext(legacy, legacyContext);
  let cases = 0;
  for (let mask = 0; mask < 8; mask++) {
    const context = { window: {}, log: { addSrcFile() {}, debug() {} }, framework: { registerCtrlLoaded() {} } };
    vm.runInNewContext(variants[mask], context);
    const proto = context.List2Ctrl.prototype, wraps = !!(mask & 4);
    if (wraps) {
      let stripped = variants[mask];
      for (const name of ['_handleMCCW', '_handleMCCCW', '_handleMCDown', '_handleMCUp']) {
        const actual = proto[name].toString();
        assert.equal(actual, legacyContext.List2Ctrl.prototype[name].toString());
        const baseline = { window: {}, log: { addSrcFile() {} }, framework: { registerCtrlLoaded() {} } };
        vm.runInNewContext(variants[mask & 3], baseline);
        stripped = stripped.replace(actual, baseline.List2Ctrl.prototype[name].toString());
      }
      assert.equal(stripped, variants[mask & 3]);
      assert.equal(typeof proto._aioWrapListFocus, 'undefined');
    }
    function control(items, focus) {
      return Object.assign(Object.create(proto), {
        focus, _topItem: 0, _hasFocus: true, _inputMode: 'controller',
        properties: { visibleItems: 5, scrollingDuringLoading: false }, m: Math,
        dataList: { items: items.map(disabled => ({ disabled })), itemCount: items.length },
        jumps: [], scrolls: 0,
        _getFocussedIndex() { return this.focus; },
        _showFocus(value) {
          if (this._inLoading) return;
          if (typeof value === 'number') { this.jumps.push(value); this.focus = value; return; }
          const direction = value === 'down' ? 1 : -1;
          for (let i = this.focus + direction; i >= 0 && i < this.dataList.items.length; i += direction) {
            if (!this.dataList.items[i].disabled) { this.focus = i; return; }
          }
        },
        _scrollDownOne() { this.scrolls++; if (!this._inLoading) { this._topItem++; this._showFocus('down'); } },
        _scrollUpOne() { this.scrolls++; if (!this._inLoading) this._topItem = Math.max(0, this._topItem - 1); }
      });
    }
    for (const [method, direction] of [['_handleMCCW', 1], ['_handleMCDown', 1], ['_handleMCCCW', -1], ['_handleMCUp', -1]]) {
      for (const [items, position, expected] of [
        [[false, false, false], direction > 0 ? 2 : 0, direction > 0 ? 0 : 2],
        [[true, false, false, true], direction > 0 ? 2 : 1, direction > 0 ? 1 : 2]
      ]) {
        const c = control(items, position); assert.equal(c[method](), 'consumed');
        assert.equal(c.focus, wraps ? expected : position); cases++;
      }
      const middle = control([false, false, false], 1); middle[method]();
      assert.equal(middle.focus, 1 + direction); assert.equal(middle.jumps.length, 0); cases++;
      const only = control([false], 0); only[method](); assert.equal(only.focus, 0); cases++;
      const disabled = control([true, true, true], 1); disabled[method]();
      assert.equal(disabled.focus, 1); assert.equal(disabled.jumps.length, 0); cases++;
      const empty = control([], null); empty[method](); assert.equal(empty.focus, null); cases++;
      const loading = control([false, false, false], direction > 0 ? 2 : 0); loading._inLoading = true;
      loading[method](); assert.equal(loading.jumps.length, 0); cases++;
    }
    const viewport = control(Array(12).fill(false), 4); viewport._handleMCCW();
    assert.equal(viewport.focus, wraps ? 0 : 5); assert.equal(viewport.jumps.length, wraps ? 1 : 0); cases++;

  }
  // Already-patched and structurally incompatible input must fail closed.
  const script = bp(path.join(root, 'docs/usb/mzd/patches/list-loop.sh'));
  await assert.rejects(promisify(execFile)('C:/Program Files/Git/bin/bash.exe', [script, 'apply', bp(path.join(dir, '4.js')), bp(path.join(dir, 'rejected.js'))]));
  const damaged = path.join(dir, 'damaged.js');
  await fs.writeFile(damaged, variants[0].replace('_handleMCCW = function()', '_renamedMCCW = function()'));
  await assert.rejects(promisify(execFile)('C:/Program Files/Git/bin/bash.exe', [script, 'apply', bp(damaged), bp(path.join(dir, 'rejected.js'))]));
  await fs.writeFile(path.join(dir, 'verification.json'), JSON.stringify({ cases, hashes, variants: 8 }, null, 2));
  return { passed: true, cases, variants: 8, fixtureDirectory: dir };
};
if (require.main === module) module.exports(process.argv[2]).then(console.log).catch(error => { console.error(error); process.exitCode = 1; });
