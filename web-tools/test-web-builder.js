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
  assert(html.includes('USB-Paket mit MP3 herunterladen'));
  assert(html.includes('sh /mnt/sda1/tweaks.sh'));
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
  document.getElementById('action').value = 'preflight';
  ids.action.selectedOptions = [{ textContent: 'Prüfen' }];
  const downloads = [], ctx = { document, TextEncoder, Blob, atob, Uint8Array,
    URL: { createObjectURL(blob) { downloads.push(blob); return 'blob:test'; }, revokeObjectURL() {} }, setTimeout() {} };
  vm.createContext(ctx);
  for (const name of ['catalog.js', 'usb-assets.js', 'builder-core.js', 'app.js']) {
    vm.runInContext(await fs.readFile(path.join(root, 'docs', name), 'utf8'), ctx);
  }
  const core = ctx.MzdBuilder, project = core.project('Test \u00e4', ['list-beep', 'list-beep']);
  assert.equal(project.tweaks.length, 1);
  assert.equal(core.parse(JSON.stringify(project)).name, 'Test \u00e4');
  assert.equal(core.usbFiles(core.project('Install', ['list-beep'], 'install'))['mzd/action.txt'], 'install\n');
  assert.equal(core.usbFiles(core.project('Both', ['list-beep', 'shorter-delay'], 'install'))['mzd/selected.txt'], 'list-beep\nshorter-delay\n');
  assert.equal(core.project('SSH experimental', ['ssh-bringback'], 'install').tweaks[0], 'ssh-bringback');
  assert.equal(core.project('Restore', ['list-beep'], 'restore').tweaks.length, 0);
  assert.throws(() => core.project('Unsupported', ['background'], 'install'));
  assert.throws(() => core.project('Unported preflight', ['background'], 'preflight'));
  assert.throws(() => core.parse(JSON.stringify({ ...project, tweaks: ['background'] })));
  assert.throws(() => core.project('Unknown action', ['list-beep'], 'unknown'));
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
  const cards = () => ids.catalog.children.flatMap(group => group.children[1].children);
  assert.equal(ids.catalog.children.length, 4);
  assert.equal(cards().length, 41);
  assert.equal(cards().filter(card => !card.children[0].children[0].disabled).length, 5);
  assert.equal(cards().filter(card => card.className.split(' ').includes('locked')).length, 36);
  assert.equal(cards().filter(card => card.className.split(' ').includes('testing')).length, 5);
  assert(cards().filter(card => !card.children[0].children[0].disabled)
    .every(card => card.children[0].children[1].textContent.endsWith(' · Zu testen')));
  // A confirmed vehicle test changes the visual status without disabling the patch.
  const confirmed = ctx.MZD_CATALOG.find(patch => patch.id === 'list-beep');
  confirmed.vehicleTested = true;
  ids.filter.events.change();
  const green = cards().find(card => card.className.split(' ').includes('tested'));
  assert(green);
  assert.equal(green.children[0].children[0].disabled, false);
  assert.equal(green.children[0].children[1].textContent, confirmed.title + ' · Getestet');
  confirmed.vehicleTested = false;
  ids.filter.events.change();
  const cb = cards().find(card => !card.children[0].children[0].disabled).children[0].children[0];
  cb.checked = true; cb.events.change();
  assert.equal(ids['selection-list'].children.length, 1);
  ids['export-zip'].events.click();
  assert.equal(downloads[0].type, 'application/zip');
  ids.filter.value = 'selected'; ids.filter.events.change();
  assert.equal(cards().length, 1);
  ids.reset.events.click(); assert.equal(cards().length, 0);
  await ids['import-file'].events.change({ target: { files: [{ size: 10, text: async () => JSON.stringify(project) }] } });
  assert.equal(ids['selection-list'].children.length, 1);
  await ids['import-file'].events.change({ target: { files: [{ size: 10, text: async () => '{invalid' }] } });
  assert.equal(ids['selection-list'].children.length, 1);
  // Device JS uses ES5 syntax; exercise the confirmed three-event sequence only.
  const events = [], timers = [], css = [], device = { document, framework: { sendEventToMmui(...args) { events.push(args); } }, log: {} };
  const timer = fn => timers.push(fn);
  vm.runInNewContext(await fs.readFile(path.join(root, 'docs/usb/js/run.js'), 'utf8'), { window: device, document, utility: { loadCss(name) { css.push(name); } }, setTimeout: timer });
  assert.equal(events.length, 0);
  assert.equal(css.length, 4);
  assert(css.every(name => name.endsWith('/css/init.css')));
  device.XSSwrapper.children[0].children[0].events.mousedown();
  while (timers.length) timers.shift()();
  assert.equal(events.length, 3);
  assert.equal(events[0][1], 'SelectDiagnostics');
  assert.equal(events[1][1], 'ActivateJCITest');
  assert.equal(events[2][2].payload.testId, 11);
  // Independently captured reference must be complete in the actual package.
  const reference = JSON.parse(await fs.readFile(path.join(root, 'docs/mp3-reference.json'), 'utf8'));
  const { createHash } = require('node:crypto');
  for (const [name, expected] of Object.entries(reference.files)) {
    assert(files[name] instanceof Uint8Array);
    assert.equal(files[name].length, expected.bytes);
    assert.equal(createHash('sha256').update(files[name]).digest('hex'), expected.sha256);
  }
  const savedCss = ctx.MZD_USB_ASSETS['css/init.css'];
  delete ctx.MZD_USB_ASSETS['css/init.css'];
  assert.throws(() => core.usbFiles(project));
  ctx.MZD_USB_ASSETS['css/init.css'] = savedCss;
  ids.filter.value = 'all'; ids.filter.events.change();
  ids.action.value = 'install'; ids.action.events.change();
  assert.equal(ids['selection-list'].children.length, 5);
  assert.equal(cards().filter(card => card.children[0].children[0].checked).length, 5);
  assert.equal(cards().filter(card => !card.children[0].children[0].disabled).length, 5);
  assert.equal(cards()[0].children[0].children[0].disabled, true);
  ids['export-json'].events.click();
  const allTests = JSON.parse(await downloads.at(-1).text());
  assert.deepEqual([...allTests.tweaks].sort(), ['list-beep', 'shorter-delay', 'main-menu-loop', 'list-loop', 'ssh-bringback'].sort());
  assert.equal(core.usbFiles(allTests)['mzd/selected.txt'].trim().split('\n').length, 5);
  // Individual deselection remains possible; uninstall preserves that choice.
  const selectedCb = cards().find(card => card.children[0].children[0].checked).children[0].children[0];
  selectedCb.checked = false; selectedCb.events.change();
  ids.action.value = 'uninstall'; ids.action.events.change();
  assert.equal(ids['selection-list'].children.length, 4);
  ids.action.value = 'restore'; ids.action.events.change();
  assert.equal(ids['selection-list'].children.length, 0);
  assert.equal(cards()[0].children[0].children[0].disabled, true);
  ids['export-zip'].events.click();
  assert.equal(downloads.at(-1).type, 'application/zip');
  await ids['import-file'].events.change({ target: { files: [{ size: 100, text: async () => JSON.stringify(core.project('Loop selection', ['list-loop'])) }] } });
  ids.action.value = 'install'; ids.action.events.change();
  assert.equal(ids['selection-list'].children.length, 5);
  assert(ids['selection-list'].children.some(item => item.textContent === 'Listen im Kreis'));
  const temp = await fs.mkdtemp(path.join(os.tmpdir(), 'mzd-builder-test-'));
  const zipPath = path.join(temp, 'usb-test.zip');
  await fs.writeFile(zipPath, core.zip(files));
  return { passed: true, zipPath, checks: 'project validation, import, UI model, binary MP3 identity, ZIP creation, manual-only diagnostic sequence' };
};
if (require.main === module) module.exports().then(console.log).catch(error => { console.error(error); process.exitCode = 1; });
