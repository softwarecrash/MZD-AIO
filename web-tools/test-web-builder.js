/* Run with node web-tools/test-web-builder.js. No browser or vehicle required. */
const fs = require('node:fs/promises');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const os = require('node:os');
const { Blob } = require('node:buffer');

module.exports = async function test() {
  const root = path.resolve(__dirname, '..');
  const html = await fs.readFile(path.join(root, 'docs/index.html'), 'utf8');
  assert(html.includes('USB-Testpaket mit MP3 herunterladen'));
  assert(html.includes('sh /mnt/sda1/mzd/start.sh'));
  assert(html.includes('usb-assets.js'));
  class Element {
    constructor() { this.children = []; this.events = {}; this.value = ''; this.files = []; this.style = {}; }
    append(...xs) { this.children.push(...xs); }
    appendChild(x) { this.append(x); }
    replaceChildren(...xs) { this.children = xs; }
    addEventListener(name, fn) { this.events[name] = fn; }
    click() {}
    remove() {}
  }
  const ids = {}, document = {
    getElementById(id) { return ids[id] ??= new Element(); },
    createElement() { return new Element(); }, body: new Element()
  };
  document.getElementById('project-name').value = 'Mein Mazda';
  document.getElementById('filter').value = 'all';
  const downloads = [], ctx = { document, TextEncoder, Blob, atob, Uint8Array,
    URL: { createObjectURL(blob) { downloads.push(blob); return 'blob:test'; }, revokeObjectURL() {} }, setTimeout() {} };
  vm.createContext(ctx);
  for (const name of ['catalog.js', 'usb-assets.js', 'builder-core.js', 'app.js']) {
    vm.runInContext(await fs.readFile(path.join(root, 'docs', name), 'utf8'), ctx);
  }
  const core = ctx.MzdBuilder, project = core.project('Test \u00e4', ['list-beep', 'list-beep']);
  assert.equal(project.tweaks.length, 1);
  assert.equal(core.parse(JSON.stringify(project)).name, 'Test \u00e4');
  for (const bad of [{ ...project, name: '' }, { ...project, tweaks: ['unknown'] },
    { ...project, tweaks: ['pause-on-mute'] }, { ...project, target: { firmware: '70', region: 'EU' } }]) {
    assert.throws(() => core.parse(JSON.stringify(bad)));
  }
  const files = core.usbFiles(project);
  assert.equal(files['mzd/selected.txt'], 'list-beep\n');
  assert.equal(JSON.parse(files['package-manifest.json']).installable, false);
  for (const name of ['a', 'b', 'c', 'd']) {
    assert.deepEqual(files['mp3/' + name + '.mp3'], new Uint8Array(await fs.readFile(path.join(root, 'docs/usb/mp3', name + '.mp3'))));
  }
  assert.equal(ids.catalog.children.length, 41);
  const cb = ids.catalog.children[0].children[0].children[0];
  cb.checked = true; cb.events.change();
  assert.equal(ids['selection-list'].children.length, 1);
  ids['export-zip'].events.click();
  assert.equal(downloads[0].type, 'application/zip');
  ids.filter.value = 'selected'; ids.filter.events.change();
  assert.equal(ids.catalog.children.length, 1);
  ids.reset.events.click(); assert.equal(ids.catalog.children.length, 0);
  await ids['import-file'].events.change({ target: { files: [{ size: 10, text: async () => JSON.stringify(project) }] } });
  assert.equal(ids['selection-list'].children.length, 1);
  await ids['import-file'].events.change({ target: { files: [{ size: 10, text: async () => '{invalid' }] } });
  assert.equal(ids['selection-list'].children.length, 1);
  // Device JS uses ES5 syntax; exercise the confirmed three-event sequence only.
  const events = [], timers = [], device = { document, framework: { sendEventToMmui(...args) { events.push(args); } }, setTimeout(fn) { timers.push(fn); } };
  vm.runInNewContext(await fs.readFile(path.join(root, 'docs/usb/js/run.js'), 'utf8'), { window: device, document });
  const panel = document.body.children.at(-1);
  assert.equal(events.length, 0); // no automatic diagnostic action
  panel.children[2].events.click();
  while (timers.length) timers.shift()();
  assert.equal(events.length, 3);
  assert.equal(events[0][1], 'SelectDiagnostics');
  assert.equal(events[1][1], 'ActivateJCITest');
  assert.equal(events[2][2].payload.testId, 11);
  const temp = await fs.mkdtemp(path.join(os.tmpdir(), 'mzd-builder-test-'));
  const zipPath = path.join(temp, 'usb-test.zip');
  await fs.writeFile(zipPath, core.zip(files));
  return { passed: true, zipPath, checks: 'project validation, import, UI model, binary MP3 identity, ZIP creation, manual-only diagnostic sequence' };
};
if (require.main === module) module.exports().then(console.log).catch(error => { console.error(error); process.exitCode = 1; });
