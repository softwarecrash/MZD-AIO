(function (window, document) {
    "use strict";
    if (window.mzdWebConsoleV1) { return; }
    window.mzdWebConsoleV1 = true;
    var running = false;
    var panel = document.createElement("div");
    panel.style.cssText = "position:fixed;left:15px;top:15px;width:580px;padding:14px;background:#fff;color:#111;font:20px sans-serif;z-index:9999999;border:3px solid #245b42;";
    var title = document.createElement("div");
    title.textContent = "MZD-AIO / 74.00.324A EU";
    panel.appendChild(title);
    var status = document.createElement("div");
    status.style.cssText = "font-size:17px;margin:12px 0;white-space:pre-wrap;";
    status.textContent = "Konsole oeffnen, im Testmenue TERMINAL waehlen und auf die Shell warten.\nDann per Tastatur eingeben:\nsh /mnt/sda1/mzd/start.sh\nBei anderem USB-Pfad: sdb1, sdc1 oder sdd1.";
    panel.appendChild(status);
    var button = document.createElement("button");
    button.textContent = "Konsole oeffnen";
    button.style.cssText = "font-size:20px;padding:12px;margin:5px;";
    button.addEventListener("click", function () {
        if (running) { return; }
        if (!window.framework || typeof window.framework.sendEventToMmui !== "function") {
            status.textContent = "Keine CMU-Schnittstelle. Hier wird keine Konsole gestartet.";
            return;
        }
        running = true;
        function failure(error) { running = false; status.textContent = "Diagnosezugang fehlgeschlagen: " + String(error); }
        try {
            window.framework.sendEventToMmui("syssettings", "SelectDiagnostics");
            window.setTimeout(function () {
                try {
                    window.framework.sendEventToMmui("diag", "ActivateJCITest");
                    window.setTimeout(function () {
                        try {
                            window.framework.sendEventToMmui("diag", "ReadDTC", { payload: { testId: 11 } });
                            running = false;
                        } catch (error) { failure(error); }
                    }, 7000);
                } catch (error) { failure(error); }
            }, 7000);
        } catch (error) { failure(error); }
    }, false);
    panel.appendChild(button);
    var close = document.createElement("button");
    close.textContent = "Anzeige schliessen";
    close.style.cssText = button.style.cssText;
    close.addEventListener("click", function () { panel.style.display = "none"; }, false);
    panel.appendChild(close);
    document.body.appendChild(panel);
})(window, document);
