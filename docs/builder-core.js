/* Browser-only project model and dependency-free ZIP (stored entries). */
(function (root) {
  "use strict";
  const target = Object.freeze({ firmware: "74.00.324A", region: "EU" });
  const catalog = root.MZD_CATALOG;
  const testableIds = Object.freeze(catalog.filter(p => p.selectable && p.releaseStatus === "experimental").map(p => p.id));
  function project(name, ids, action = "preflight") {
    if (typeof name !== "string" || !name.trim() || name.trim().length > 80) throw new Error("Bitte einen Projektnamen mit 1 bis 80 Zeichen eingeben.");
    if (!Array.isArray(ids) || ids.some(id => typeof id !== "string" || !catalog.some(p => p.id === id && p.selectable))) throw new Error("Das Projekt enthält unbekannte oder nicht auswählbare Tweaks.");
    if (ids.some(id => !testableIds.includes(id))) throw new Error("Noch nicht bearbeitete Tweaks sind gesperrt. Bitte nur zum Testen freigegebene Patches auswählen.");
    if (!["preflight", "install", "uninstall", "restore"].includes(action)) throw new Error("Unbekannte Aktion.");
    if (["install", "uninstall"].includes(action) && ids.length === 0) throw new Error("Bitte mindestens einen zum Testen freigegebenen Patch auswählen.");
    return { format: "mzd-aio-web-project", version: 1, name: name.trim(), status: "draft", target: { ...target }, action, tweaks: action === "restore" ? [] : [...new Set(ids)] };
  }
  function parse(text) {
    const value = JSON.parse(text);
    if (!value || value.format !== "mzd-aio-web-project" || value.version !== 1 || value.target?.firmware !== target.firmware || value.target?.region !== target.region) throw new Error("Unterstützt werden nur MZD-AIO-Projekte für 74.00.324A EU (Format 1).");
    return project(value.name, value.tweaks, value.action);
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
    const clean = project(value.name, value.tweaks, value.action), selected = clean.tweaks.map(id => catalog.find(p => p.id === id));
    return {
      "project.json": JSON.stringify(clean, null, 2) + "\n",
      "patch-status.json": JSON.stringify({ target, installable: false, patches: selected }, null, 2) + "\n",
      "README.txt": "MZD-AIO WEB / PROJEKTENTWURF\nFirmware: 74.00.324A EU\n\nDieses ZIP ist kein Installationspaket. Es enthält keine Installer oder Fahrzeug-Payloads.\nAlle gewählten Tweaks benötigen noch eine v74-Portierung und einen Fahrzeugtest.\nProjekt über project.json im Web-Builder wieder öffnen.\n\nAuswahl:\n" + (selected.map(p => "- " + p.title).join("\n") || "Keine Tweaks ausgewählt.") + "\n"
    };
  }
  function usbFiles(value) {
    const clean = project(value.name, value.tweaks, value.action), files = draftFiles(clean);
    if (!root.MZD_USB_ASSETS) throw new Error("USB-Dateien fehlen. Bitte die Seite neu laden.");
    for (const [path, asset] of Object.entries(root.MZD_USB_ASSETS)) {
      const raw = atob(asset.base64), bytes = Uint8Array.from(raw, c => c.charCodeAt(0));
      if (bytes.length !== asset.bytes) throw new Error("USB-Datei unvollständig: " + path);
      files[path] = bytes;
    }
    files["mzd/selected.txt"] = clean.tweaks.join("\n") + (clean.tweaks.length ? "\n" : "");
    files["mzd/action.txt"] = clean.action + "\n";
    files["mzd/allowed.txt"] = catalog.filter(p => p.selectable).map(p => p.id).join("\n") + "\n";
    files["README.txt"] = "MZD-AIO WEB / 74.00.324A EU\nAktion: " + clean.action + "\n\n"
      + "1. ZIP vollstaendig ins Hauptverzeichnis eines FAT32-USB-Sticks entpacken.\n"
      + "2. USB-Audio oeffnen und mp3/a.mp3 abspielen. Falls das Fenster nicht erscheint, b.mp3, c.mp3 oder d.mp3 versuchen. Diese verwenden sda1 bis sdd1.\n"
      + "3. Im Fenster Konsole oeffnen druecken. Nach etwa 14 Sekunden erscheint das OEM-Testmenue; dort TERMINAL waehlen und auf die Shell warten.\n"
      + "4. Per USB-Tastatur eingeben: sh /mnt/sda1/tweaks.sh\n"
      + "   Falls Datei nicht gefunden: sda1 durch sdb1, sdc1 oder sdd1 ersetzen.\n"
      + "5. Berichte unter reports/<Zeit>-<PID>/ auf demselben Stick pruefen: run.log (Ausgabe und Fehler), status.txt (Exit-Code), preflight.txt (Dateivergleich, sofern erreicht). Auch fruehe Abbrueche werden protokolliert.\n\n"
      + "Pruefen veraendert nichts. Install/Uninstall unterstuetzen Listenpiepsen, Listendelay und SSH, einzeln und gemeinsam. Experimentell; Fahrzeugtest offen. Vor Aenderungen im Terminal mit j bestaetigen.\n"
      + "SSH: Port 22, Benutzer cmu, Passwort jci. Der OEM-Dienst auf Port 36000 bleibt bestehen. Fremd belegter Port 22 fuehrt zum Abbruch. Kein zweiter eigener Listener. Der Start nach Neustart wird ueber stage_wifi eingerichtet. WLAN-Verbindung bleibt Aufgabe der Firmware.\n"
      + "SSH verwendet eine temporaere Kontenueberlagerung im RAM, keine Flash-Aenderung an Konten. Uninstall/Full System Restore entfernen Boot-Hook, eigenen Dienst, eigene Firewallfreigabe und Kontenueberlagerung. Keine persoenlichen Schluessel erforderlich.\n"
      + "SSH-Startberichte werden auf einen passenden beschreibbaren USB geschrieben. Ohne USB funktioniert der Zugang trotzdem; Laufzeitlogs werden dann verworfen, niemals intern gespeichert. Der Boot-Hook haengt von stage_3/jciMMUI ab: kein garantierter Rettungszugang bei fruehen Boot-/MMUI-Fehlern. WLAN muss funktionieren.\n"
      + "Install fuegt die Auswahl hinzu; Uninstall entfernt nur die Auswahl. Andere aktive Patches bleiben erhalten. Die Datei wird aus dem Original und der gespeicherten aktiven Patchliste neu erzeugt. Ihr zuletzt geschriebener Hash erkennt fremde Aenderungen.\n"
      + "Originale bleiben intern unter /resources/aio-rework/backups/74.00.324A-EU/ erhalten; zusaetzliche Kopie auf diesem USB unter backups/. Installiert/Original wird automatisch erkannt.\n"
      + "Full System Restore ignoriert die Tweak-Auswahl und stellt alle derzeit unterstuetzten, von uns verwalteten Systemdateien wieder her. Alternativ direkt: sh /mnt/sda1/restore.sh . Ein neuer Stick reicht; die Originale liegen intern. Keine Wiederherstellung fremder AIO-Installationen oder Werksreset.\n"
      + "Der MP3-Konsolenzugang mit Tastatur ist der vom Besitzer bestaetigte Weg; dieses neu zusammengestellte Paket ist noch nicht am Fahrzeug getestet.\n"
      + "Keine automatische SSH-Aktivierung oder automatischer Neustart. Nach erfolgreicher Aenderung CMU selbst neu starten. Logs bleiben auf dem Start-USB.\n\n"
      + "Auswahl im Browser wieder oeffnen: project.json\n";
    files["patch-status.json"] = JSON.stringify({ target, action: clean.action, experimental: true, vehicleTested: false, patches: clean.tweaks }, null, 2) + "\n";
    files["package-manifest.json"] = JSON.stringify({ format: "mzd-aio-usb", version: 1, target,
      installable: clean.action !== "preflight", mode: clean.action, experimental: true, vehicleTested: false,
      entry: "mp3-console-keyboard", command: "sh /mnt/sda1/tweaks.sh", appsToResources: true,
      assets: Object.fromEntries(Object.entries(root.MZD_USB_ASSETS).map(([path, a]) => [path, { bytes: a.bytes, sha256: a.sha256 }])) }, null, 2) + "\n";
    return files;
  }
  root.MzdBuilder = Object.freeze({ target, testableIds, project, parse, zip, draftFiles, usbFiles });
})(globalThis);
