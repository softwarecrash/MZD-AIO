(function (window, document) {
    "use strict";
    if (window.mzdKeyboardlessProbeV1) { return; }
    var state = { running: false };
    window.mzdKeyboardlessProbeV1 = state;
    var panel = document.createElement("div");
    panel.style.cssText = "position:fixed;left:15px;top:15px;width:580px;padding:14px;background:#fff;color:#111;font:20px sans-serif;z-index:9999999;border:3px solid #167048;";
    var title = document.createElement("div");
    title.textContent = "MAZDA: MP3 -> KONSOLE -> SSH TEST v1";
    panel.appendChild(title);
    var status = document.createElement("div");
    status.style.cssText = "font-size:17px;margin:12px 0;white-space:pre-wrap;";
    panel.appendChild(status);
    function message(text) { status.textContent = text; }
    function launch() {
        if (state.running) { return; }
        if (!window.framework || typeof window.framework.sendEventToMmui !== "function") {
            message("Keine CMU-Schnittstelle. Browser-Vorschau: es wird nichts gestartet.");
            return;
        }
        state.running = true;
        try {
            message("MP3-JavaScript laeuft. Diagnose wird geoeffnet...\nOhne einmaligen RAM-Hook erscheint nur das originale Testmenue.");
            window.framework.sendEventToMmui("syssettings", "SelectDiagnostics");
            window.setTimeout(function () {
                try {
                    window.framework.sendEventToMmui("diag", "ActivateJCITest");
                    message("JCI-Testmodus angefordert. Noch etwa 7 Sekunden...");
                    window.setTimeout(function () {
                        try {
                            window.framework.sendEventToMmui("diag", "ReadDTC", { payload: { testId: 11 } });
                            message("Test 11 angefordert.\nMit RAM-Hook: Terminal und SSH auf Port 2223.\nOhne RAM-Hook: originales Testmenue; kein automatisches SSH.\nErfolg erst nach neuer SSH-Anmeldung bestaetigen.");
                        } catch (error) { message("Test 11 fehlgeschlagen: " + String(error)); }
                        state.running = false;
                    }, 7000);
                } catch (error) { state.running = false; message("Testmodus fehlgeschlagen: " + String(error)); }
            }, 7000);
        } catch (error) { state.running = false; message("Diagnose fehlgeschlagen: " + String(error)); }
    }
    function button(label, callback) {
        var element = document.createElement("button");
        element.textContent = label;
        element.style.cssText = "font-size:20px;padding:10px;margin:4px;";
        element.addEventListener("click", callback, false);
        panel.appendChild(element);
    }
    button("Erneut starten", launch);
    button("Anzeige schliessen", function () { panel.style.display = "none"; });
    document.body.appendChild(panel);
    window.setTimeout(launch, 1500);
})(window, document);
