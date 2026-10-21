(function () {
  "use strict";

  const form = document.getElementById("project-form");
  const nameInput = document.getElementById("project-name");
  const firmwareInput = document.getElementById("firmware");
  const status = document.getElementById("project-status");

  nameInput.addEventListener("input", function () {
    nameInput.setCustomValidity("");
    status.textContent = "";
  });

  form.addEventListener("submit", function (event) {
    event.preventDefault();
    const name = nameInput.value.trim();
    if (!name) {
      nameInput.setCustomValidity("Bitte gib deinem Projekt einen Namen.");
      nameInput.reportValidity();
      return;
    }
    const project = {
      format: "mzd-aio-web-project",
      version: 1,
      name: name,
      status: "draft",
      target: { firmware: firmwareInput.value, region: "EU" },
      tweaks: []
    };
    const blob = new Blob([JSON.stringify(project, null, 2) + "\n"], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "mzd-aio-projekt.json";
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
    status.textContent = "Projektdatei zum Download bereitgestellt. Die Tweak-Auswahl folgt später.";
  });
})();
