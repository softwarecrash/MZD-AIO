# Quellcode-Landkarte

Ausgangsstand: `409c724ed860497b2a34f9367cb4a019287846ea` (Fork/master beim Recherchebeginn). Die Dateien sind relativ zum Repository verlinkt.

| Bereich | Dateien | Bedeutung für den Rework |
|---|---|---|
| Desktop-Build | [package.json](../package.json), [app/package.json](../app/package.json), [scripts/](../scripts/) | Electron 6 / Node-13-Vorgaben, native Module, altes Packaging/Updater-Konzept |
| Desktop-Start | [app/main.js](../app/main.js), [app/index.html](../app/index.html) | Updater/Translate und Netzabhängigkeiten; PR #230 |
| Paketerstellung | [build-tweaks.js](../app/assets/js/build-tweaks.js) | Zusammenfügen der Tweakbausteine, Kopieren von Ressourcen, USB, LF-Normalisierung; addWifiAP / buildAutorunInstaller / convert2LF |
| Erkennung / Rahmen | [00_start.txt](../app/files/tweaks/00_start.txt) | Firmwaregruppen, Logging, Integrity-Check, Vorarbeiten; kein eigener v74-Zweig |
| App-Menü | [00_59patch.txt](../app/files/tweaks/00_59patch.txt) | Kann komplette systemApp.js anhand alter Firmwaregruppen ersetzen |
| Audioquellen | [09_audioorder-i.txt](../app/files/tweaks/09_audioorder-i.txt), [09_audioorder-u.txt](../app/files/tweaks/09_audioorder-u.txt) | Mehrere komplette systemApp-Varianten; Konflikte mit Disclaimer/CP beachten |
| WLAN im Menü | [00_wifi.txt](../app/files/tweaks/00_wifi.txt) | Text-/sed-Änderung in syssettingsApp.js mit Regionsbezug |
| SSH Bringback | [00_sshbringback.txt](../app/files/tweaks/00_sshbringback.txt), [Konfiguration](../app/files/tweaks/config/ssh_bringback/) | Firewall-, passwd-/Schlüssel-/SSH-Dateien; kein reiner Ein-Aus-Schalter |
| Autorun / Recovery | [cmu-autorun/](../app/files/tweaks/cmu-autorun/) | Installation, laufende Hintergrundskripte, AP/ADB/SSH und Deinstallation |
| AIO-AA | [androidauto/](../app/files/tweaks/config/androidauto/) | Eigene Headunit-Binärprogramme/Wrapper; unabhängig von OEM-AA |
| Speedometer | [speedometer/](../app/files/tweaks/config/speedometer/) | Datenzugriff und Anzeige, separates Upstream-Projekt beachten |
| Video | [17_videoplayer-i.txt](../app/files/tweaks/17_videoplayer-i.txt) | GStreamer-Sinks und Firmwaregruppen |
| USB-Audio | [26_usbaudiomod-i.txt](../app/files/tweaks/26_usbaudiomod-i.txt) | Bereits für spätere v59 ausgeschlossen |
| Restore | [00___fullRestore.sh](../app/files/tweaks/00___fullRestore.sh) | Kritischer Rückbau; historisch kein garantierter Universalweg |

## Statisch bestätigte Details

- Firmwarekommentare und numerische Grenzen sind nicht überall konsistent.
- `compatibility_check()` liefert für 74 den unbekannten Fall 0.
- Audio-/App-Menü-Bausteine enthalten vollständigen Dateiaustausch, nicht ausschließlich kleine sed-Patches.
- `00_sshbringback.txt` kann die komplette SSH-/Authentifizierungs-/Firewallbasis ändern.
- `convert2LF()` normalisiert das generierte `tweaks.txt`; das behebt nicht automatisch die CRLF-Datei in #226.
- Quellcode und Logs belegen installerabhängige Platzprobleme. Freien Speicher auf `rootfs`, `resources` und `data_persist` getrennt behandeln.
- Das Repository enthält vorgefertigte Binär- und OEM-nahe Dateien. Herkunft und Varianten sind vor einer neuen Veröffentlichung einzeln zu klären; aus einem GPL-Hinweis in package.json folgt keine Herkunftsgarantie für jede beigepackte Ressource.

Die [automatische Bausteinliste](TWEAK_INVENTORY.md) ist eine Bestandsaufnahme, kein Audit sämtlicher Binärdateien und keine Kompatibilitätsfreigabe.
