(function () {
  "use strict";
  const byId = id => document.getElementById(id), core = globalThis.MzdBuilder;
  const selected = new Set(), labels = { TEXT_KANDIDAT: "Text-Kandidat", CSS_KANDIDAT: "CSS-Kandidat", ANPASSEN: "Anpassung nötig", NICHT_UNVERAENDERT: "Ersetzung überarbeiten", ASSET_PRUEFUNG: "Grafiken prüfen", LAUFZEIT_OFFEN: "Laufzeit offen", ALTEN_TWEAK_WEGLASSEN: "Alter Tweak entfällt" };
  const status = byId("project-status");
  const categories = { patches: "Patches & Bedienung", ui: "Oberfläche & Design", apps: "Apps", system: "System & Diagnose" };
  function render() {
    const mode = byId("action").value;
    const query = byId("search").value.trim().toLocaleLowerCase("de"), filter = byId("filter").value;
    const rows = globalThis.MZD_CATALOG.filter(p => (p.title + " " + p.description).toLocaleLowerCase("de").includes(query) && (filter !== "selected" || selected.has(p.id)) && (filter !== "candidate" || ["TEXT_KANDIDAT", "CSS_KANDIDAT"].includes(p.auditStatus)));
    byId("catalog").replaceChildren();
    const lists = {};
    for (const [id, name] of Object.entries(categories)) {
      const count = rows.filter(p => p.category === id).length;
      if (!count) continue;
      const section = document.createElement("section"), heading = document.createElement("h3"), list = document.createElement("div");
      section.className = "category-group"; heading.className = "category-heading";
      heading.textContent = name + " · " + count; list.className = "category-tweaks";
      section.append(heading, list); byId("catalog").append(section); lists[id] = list;
    }
    for (const patch of rows) {
      const card = document.createElement("article"); card.className = "tweak-card" + (selected.has(patch.id) ? " chosen" : "");
      const label = document.createElement("label"), checkbox = document.createElement("input"), title = document.createElement("span");
      checkbox.type = "checkbox"; checkbox.checked = selected.has(patch.id);
      checkbox.disabled = mode === "restore" || !core.testableIds.includes(patch.id);
      title.textContent = patch.title; label.append(checkbox, title);
      checkbox.addEventListener("change", () => { if (checkbox.checked) selected.add(patch.id); else selected.delete(patch.id); status.textContent = ""; render(); });
      const badge = document.createElement("span"); badge.className = "patch-status";
      badge.textContent = patch.releaseStatus === "experimental" ? "Zum Testen freigegeben · Fahrzeugtest offen" : "Gesperrt · In Planung · " + labels[patch.auditStatus];
      const description = document.createElement("p"); description.textContent = patch.description;
      card.append(label, badge, description); lists[patch.category].append(card);
    }
    byId("result-count").textContent = rows.length + " Tweaks · " + core.testableIds.length + " zum Testen freigegeben";
    byId("empty").hidden = rows.length > 0;
    byId("selection-count").textContent = selected.size + " Tweaks ausgewählt";
    byId("release-info").textContent = mode === "restore"
      ? "Full System Restore stellt alle von diesem Rework verwalteten Systemdateien aus den internen Originalen wieder her. Die Tweak-Auswahl wird ignoriert."
      : mode === "preflight" ? "Prüfen verändert keine Systemdateien. Noch nicht bearbeitete Tweaks sind gesperrt."
      : "Ausführbar: Listenpiepsen, Listendelay und SSH. Experimentell; Fahrzeugtest offen. Andere aktive Patches bleiben beim Installieren und Deinstallieren erhalten.";
    byId("selection-list").replaceChildren();
    for (const id of selected) { const li = document.createElement("li"); li.textContent = globalThis.MZD_CATALOG.find(p => p.id === id).title; byId("selection-list").append(li); }
  }
  function current() { return core.project(byId("project-name").value, [...selected], byId("action").value); }
  function save(bytes, name, type) {
    const url = URL.createObjectURL(new Blob([bytes], { type })), a = document.createElement("a");
    a.href = url; a.download = name; document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
  }
  function action(fn) { try { fn(); } catch (error) { status.textContent = error.message; } }
  byId("search").addEventListener("input", render); byId("filter").addEventListener("change", render);
  byId("action").addEventListener("change", () => {
    const mode = byId("action").value;
    if (mode === "restore") selected.clear();
    else if (mode === "install") {
      selected.clear();
      core.testableIds.forEach(id => selected.add(id));
    } else {
      for (const id of selected) if (!core.testableIds.includes(id)) selected.delete(id);
    }
    status.textContent = ""; render();
  });
  byId("export-json").addEventListener("click", () => action(() => { save(JSON.stringify(current(), null, 2) + "\n", "mzd-aio-projekt.json", "application/json"); status.textContent = "Projektdatei zum Download bereitgestellt."; }));
  byId("export-zip").addEventListener("click", () => action(() => { const project = current(); save(core.zip(core.usbFiles(project)), "mzd-aio-74.00.324A-EU-" + project.action + ".zip", "application/zip"); status.textContent = "USB-Paket bereitgestellt. Aktion: " + byId("action").selectedOptions[0].textContent + ". Start und Hinweise stehen in README.txt."; }));
  byId("import-file").addEventListener("change", async event => {
    const file = event.target.files[0]; if (!file) return;
    try {
      if (file.size > 1024 * 1024) throw new Error("Projektdateien dürfen höchstens 1 MB groß sein.");
      const value = core.parse(await file.text());
      selected.clear(); value.tweaks.forEach(id => selected.add(id)); byId("project-name").value = value.name; byId("action").value = value.action; render(); status.textContent = "Projekt geöffnet.";
    } catch (error) { status.textContent = "Öffnen fehlgeschlagen: " + error.message; }
    event.target.value = "";
  });
  byId("reset").addEventListener("click", () => { selected.clear(); render(); status.textContent = "Auswahl zurückgesetzt."; });
  render();
})();
