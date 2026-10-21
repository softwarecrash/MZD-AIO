/* Browser-only project model and dependency-free ZIP (stored entries). */
(function (root) {
  "use strict";
  const target = Object.freeze({ firmware: "74.00.324A", region: "EU" });
  const catalog = root.MZD_CATALOG;
  function project(name, ids) {
    if (typeof name !== "string" || !name.trim() || name.trim().length > 80) throw new Error("Bitte einen Projektnamen mit 1 bis 80 Zeichen eingeben.");
    if (!Array.isArray(ids) || ids.some(id => typeof id !== "string" || !catalog.some(p => p.id === id && p.selectable))) throw new Error("Das Projekt enthält unbekannte oder nicht auswählbare Tweaks.");
    return { format: "mzd-aio-web-project", version: 1, name: name.trim(), status: "draft", target: { ...target }, tweaks: [...new Set(ids)] };
  }
  function parse(text) {
    const value = JSON.parse(text);
    if (!value || value.format !== "mzd-aio-web-project" || value.version !== 1 || value.target?.firmware !== target.firmware || value.target?.region !== target.region) throw new Error("Unterstützt werden nur MZD-AIO-Projekte für 74.00.324A EU (Format 1).");
    return project(value.name, value.tweaks);
  }
  function crc32(bytes) {
    let crc = 0xffffffff;
    for (const byte of bytes) { crc ^= byte; for (let i = 0; i < 8; i++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0); }
    return (crc ^ 0xffffffff) >>> 0;
  }
  function zip(files) {
    const encoder = new TextEncoder(), parts = [], directory = []; let offset = 0, size = 0;
    for (const [name, text] of Object.entries(files)) {
      const filename = encoder.encode(name), data = text instanceof Uint8Array ? text : encoder.encode(text), crc = crc32(data);
      const header = new Uint8Array(30), h = new DataView(header.buffer);
      h.setUint32(0, 0x04034b50, true); h.setUint16(4, 20, true); h.setUint16(6, 0x800, true); h.setUint16(12, 0x21, true);
      h.setUint32(14, crc, true); h.setUint32(18, data.length, true); h.setUint32(22, data.length, true); h.setUint16(26, filename.length, true);
      parts.push(header, filename, data);
      const central = new Uint8Array(46), c = new DataView(central.buffer);
      c.setUint32(0, 0x02014b50, true); c.setUint16(4, 20, true); c.setUint16(6, 20, true); c.setUint16(8, 0x800, true); c.setUint16(14, 0x21, true);
      c.setUint32(16, crc, true); c.setUint32(20, data.length, true); c.setUint32(24, data.length, true); c.setUint16(28, filename.length, true); c.setUint32(42, offset, true);
      directory.push(central, filename); size += central.length + filename.length; offset += header.length + filename.length + data.length;
    }
    const end = new Uint8Array(22), e = new DataView(end.buffer), count = Object.keys(files).length;
    e.setUint32(0, 0x06054b50, true); e.setUint16(8, count, true); e.setUint16(10, count, true); e.setUint32(12, size, true); e.setUint32(16, offset, true);
    const result = new Uint8Array(offset + size + end.length); let cursor = 0;
    for (const part of [...parts, ...directory, end]) { result.set(part, cursor); cursor += part.length; }
    return result;
  }
  function draftFiles(value) {
    const clean = project(value.name, value.tweaks), selected = clean.tweaks.map(id => catalog.find(p => p.id === id));
    return {
      "project.json": JSON.stringify(clean, null, 2) + "\n",
      "patch-status.json": JSON.stringify({ target, installable: false, patches: selected }, null, 2) + "\n",
      "README.txt": "MZD-AIO WEB / PROJEKTENTWURF\nFirmware: 74.00.324A EU\n\nDieses ZIP ist kein Installationspaket. Es enthält keine Installer oder Fahrzeug-Payloads.\nAlle gewählten Tweaks benötigen noch eine v74-Portierung und einen Fahrzeugtest.\nProjekt über project.json im Web-Builder wieder öffnen.\n\nAuswahl:\n" + (selected.map(p => "- " + p.title).join("\n") || "Keine Tweaks ausgewählt.") + "\n"
    };
  }
  function usbFiles(value) {
    const clean = project(value.name, value.tweaks), files = draftFiles(clean);
    if (!root.MZD_USB_ASSETS) throw new Error("USB-Dateien fehlen. Bitte die Seite neu laden.");
    for (const [path, asset] of Object.entries(root.MZD_USB_ASSETS)) {
      const raw = atob(asset.base64), bytes = Uint8Array.from(raw, c => c.charCodeAt(0));
      if (bytes.length !== asset.bytes) throw new Error("USB-Datei unvollständig: " + path);
      files[path] = bytes;
    }
    files["mzd/selected.txt"] = clean.tweaks.join("\n") + (clean.tweaks.length ? "\n" : "");
    files["mzd/allowed.txt"] = catalog.filter(p => p.selectable).map(p => p.id).join("\n") + "\n";
    files["README.txt"] = "MZD-AIO WEB / MP3-KONSOLENSTART + VORPRUEFUNG\n74.00.324A EU\n\n"
      + "1. ZIP vollstaendig ins Hauptverzeichnis eines FAT32-USB-Sticks entpacken.\n"
      + "2. USB-Audio oeffnen und mp3/a.mp3 abspielen. Falls das Fenster nicht erscheint, b.mp3, c.mp3 oder d.mp3 versuchen. Diese verwenden sda1 bis sdd1.\n"
      + "3. Im Fenster Konsole oeffnen druecken. Nach etwa 14 Sekunden erscheint das OEM-Testmenue; dort TERMINAL waehlen und auf die Shell warten.\n"
      + "4. Per USB-Tastatur eingeben: sh /mnt/sda1/mzd/start.sh\n"
      + "   Falls Datei nicht gefunden: sda1 durch sdb1, sdc1 oder sdd1 ersetzen.\n"
      + "5. Ausgabe und reports/<Zeit>-<PID>/preflight.txt auf dem Stick pruefen.\n\n"
      + "Dieser Stand startet nur die Vorpruefung: Firmware, Auswahl und drei OEM-Dateihashes. Keine Tweaks werden installiert. MD5 identifiziert bekannte Dateistaende und ist keine Signatur.\n"
      + "Der MP3-Konsolenzugang mit Tastatur ist der vom Besitzer bestaetigte Weg; dieses neu zusammengestellte Paket ist noch nicht am Fahrzeug getestet.\n"
      + "Kein automatischer Shellbefehl, kein RAM-Hook, keine SSH-Aktivierung, keine Aenderung von OEM-Dateien. Berichte werden auf USB geschrieben.\n\n"
      + "Auswahl im Browser wieder oeffnen: project.json\n";
    files["package-manifest.json"] = JSON.stringify({ format: "mzd-aio-usb-preflight", version: 1, target,
      installable: false, mode: "preflight", entry: "mp3-console-keyboard", command: "sh /mnt/sda1/mzd/start.sh",
      assets: Object.fromEntries(Object.entries(root.MZD_USB_ASSETS).map(([path, a]) => [path, { bytes: a.bytes, sha256: a.sha256 }])) }, null, 2) + "\n";
    return files;
  }
  root.MzdBuilder = Object.freeze({ target, project, parse, zip, draftFiles, usbFiles });
})(globalThis);
