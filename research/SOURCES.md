# Quellen und Arbeitsmaterial

Stand 21.10.2026. Der vollständige Linkkatalog enthält 1655 Fundstellen in [referenced-links.json](evidence/referenced-links.json). Diese Links wurden aus den archivierten Diskussionen extrahiert; der Katalog ist **keine** Bestätigung aktueller Erreichbarkeit, Integrität oder Kompatibilität aller Ziele.

## Hauptquelle und feste Stände

- Original: https://github.com/Trevelopment/MZD-AIO
- Arbeitsfork: https://github.com/softwarecrash/MZD-AIO
- Ausgangscommit: `409c724ed860497b2a34f9367cb4a019287846ea`.
- Issue-/PR-Diskussionen: [Snapshot](upstream-snapshot.json), [Index](ISSUE_INDEX.md).
- Offene PRs: jedes JSON enthält den ausgewerteten Head- und Base-SHA. Die Änderungen wurden gespeichert, nicht angewandt.

## Verknüpfte Projekte

| Projekt | Nutzen | Aufbewahrter Stand / Lizenzhinweis |
|---|---|---|
| [mzd-evo/mzd-connect-1-root](https://github.com/mzd-evo/mzd-connect-1-root) | MP3-/UI-Einstieg in Diagnose/Terminal | Commit `b1f7a7e082cb88c78183dd94cdb87bd4b02dae60`; js/run.js gelesen. Keine Lizenz aus Repository-Metadaten ausgewiesen; nicht ungeprüft als eigene Ressource bündeln. |
| [shunceyb/mzd74-tweaks-no-touch](https://github.com/shunceyb/mzd74-tweaks-no-touch) | Automatischer Einstieg bei defektem Touch, Ablauf bis SSH | Commit `3f46ef4d2057c6e6b0170a7f79b17390c176beba`; README gelesen. Keine Lizenz aus Metadaten ausgewiesen; Anleitung nicht als eigene v74-Testbestätigung behandeln. |
| [Trevelopment/MZD_Speedometer](https://github.com/Trevelopment/MZD_Speedometer) | Historischer speedometer.js-Fix (#45) | GPL-3.0 laut Repository-Metadaten; konkrete Datei vor Übernahme pinnen. |
| [gartnera/headunit](https://github.com/gartnera/headunit) | Legacy-AA, C++/Audio/USB | AGPL-3.0 laut Metadaten; eigenständiges Projekt, nicht OEM-AA. |
| [Trevelopment/cmu-autorun](https://github.com/Trevelopment/cmu-autorun) | Recovery/Autorun und Ressourcenfundstellen | Separate Herkunft und Lizenzen prüfen. |
| [Trevelopment/Mazda-Videoplayer](https://github.com/Trevelopment/Mazda-Videoplayer) | GStreamer-/Surface-Hinweise | Projektstand separat untersuchen. |
| [silverchris/mazda-cmu-documentation](https://github.com/silverchris/mazda-cmu-documentation) | Hardware, Speicher, Steckverbinder, Busse | Reverse-Engineering-Dokumentation; Pinbelegung am konkreten Gerät prüfen. |
| [Trevelopment/mazda-custom-application-sdk-simulator](https://github.com/Trevelopment/mazda-custom-application-sdk-simulator) | CMU-Datenpunkte/GUI-Simulator, #2/#39 | Verlinkte Datenlisten noch nicht als vollständiger Abgleich einer v74-CMU geprüft. |
| [TTigges/mzd-usb-sensors](https://github.com/TTigges/mzd-usb-sensors) | Externe Sensoren, Fund in #39 | Weiterführende Spur, keine Integration erfolgt. |
| [JonesChi/CastScreen](https://github.com/JonesChi/CastScreen) | Castscreen-Receiver und Kontextprobleme | #30/#60; Vorschläge nicht als fertigen Patch ausgeben. |

## Besonders brauchbare Fundstellen

- [Farbschemata-ZIP auf GitHub Releases](https://github.com/Trevelopment/cmu-autorun/releases/download/1/color-schemes.zip) – Herkunft: Maintainerkommentar #111; manuelles Entpacken positiv rückgemeldet. Inhalt, Lizenz und Hash hier noch nicht geprüft.
- [tweaks.txt aus #78](https://github.com/Trevelopment/MZD-AIO/files/4292288/tweaks.txt) – historisch als Ersatz für tweaks.sh bereitgestellt, Erfolg in #78/#74; vor Übernahme mit heutigem Quellcode vergleichen.
- [NO_MORE_BEEPS.zip aus #24](https://github.com/Trevelopment/MZD-AIO/files/2544807/NO_MORE_BEEPS.zip) – korrigierte zweite Variante; erste Variante verursachte Freeze. Keine Freigabe für v74.
- [StatusBarSpeedometer.css.zip aus #21](https://github.com/Trevelopment/MZD-AIO/files/2399791/StatusBarSpeedometer.css.zip) – historische bestätigte CSS-Korrektur.
- [Touch-Deaktivierung im Forum](https://www.mazda3revolution.com/attachments/fully-disable-touchscreen-zip-pdf.283003/) – wiedergefundene Ressource aus #118/#127/#155/#171. Inhalt nicht geprüft; Umbenennen allein beweist keinen echten ZIP-Inhalt.
- [Ursprüngliche v74-AIO-Diskussion](https://www.mazda3revolution.com/threads/mzd-aio-tweak-on-fw-74.252435/) – in #228 und dem No-Touch-Projekt verlinkt. Der vollständige Forumsthread ist in diesem GitHub-Recherchelauf nicht archiviert/ausgewertet.

## Firmwarestand des Nutzers

Nutzerhinweis: alte E-Mail nennt **74.00.311 EU N**. Aktuell installiert noch am Gerät prüfen. Späterer regulärer EU-Stand **74.00.324 EU N / 74.00.324A EU N**: [Originalbeitrag von ASH8](https://forum.miata.net/vb/showthread.php?page=83&t=679114). Ein neuerer regulärer EU-Stand wurde in diesem Lauf nicht belastbar belegt. Kein Firmwarepaket wurde heruntergeladen oder ins Repository kopiert.

## In Issues verlinkte nicht-bildliche GitHub-Anhänge

**Nur Fundstellen:** Dateinamen sind vom jeweiligen Autor gewählt. Logs, ZIPs und alte Installer sind nicht ausgeführt, nicht als vollständig geprüft markiert und nicht automatisch für v74 geeignet.

| Anhang | Fundstelle |
|---|---|
| [AIO_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2639370/AIO_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/35) |
| [StatusBarSpeedometer.zip](https://github.com/Trevelopment/MZD-AIO/files/2399791/StatusBarSpeedometer.zip) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/21#issuecomment-423045573) |
| [NO_MORE_BEEPS.zip)**](https://github.com/Trevelopment/MZD-AIO/files/2544807/NO_MORE_BEEPS.zip)**) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/24#issuecomment-435572976) |
| [AIO_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2636403/AIO_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/34#issuecomment-443466708) |
| [AIO_log.log](https://github.com/Trevelopment/MZD-AIO/files/2636408/AIO_log.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/34#issuecomment-443467100) |
| [info.log](https://github.com/Trevelopment/MZD-AIO/files/2636409/info.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/34#issuecomment-443467100) |
| [node.log](https://github.com/Trevelopment/MZD-AIO/files/2636410/node.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/34#issuecomment-443467100) |
| [AIO_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2636411/AIO_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/34#issuecomment-443467100) |
| [MZD-AIO-TI.log](https://github.com/Trevelopment/MZD-AIO/files/2707730/MZD-AIO-TI.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-449770443) |
| [MZD-AIO-TI.Crashes.zip](https://github.com/Trevelopment/MZD-AIO/files/2752295/MZD-AIO-TI.Crashes.zip) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453763937) |
| [operation_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2752296/operation_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453763937) |
| [operation_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2752388/operation_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453771738) |
| [operation_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2752385/operation_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453771738) |
| [MZD-AIO-TI.log](https://github.com/Trevelopment/MZD-AIO/files/2752386/MZD-AIO-TI.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453771738) |
| [MZD-AIO-TI.log](https://github.com/Trevelopment/MZD-AIO/files/2752395/MZD-AIO-TI.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453771738) |
| [MZD-AIO-TI.Crashes.zip](https://github.com/Trevelopment/MZD-AIO/files/2752402/MZD-AIO-TI.Crashes.zip) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453772221) |
| [operation_log.txt](https://github.com/Trevelopment/MZD-AIO/files/2752403/operation_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/40#issuecomment-453772221) |
| [node.log](https://github.com/Trevelopment/MZD-AIO/files/4081229/node.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/36#issuecomment-575922092) |
| [AIO_log.log](https://github.com/Trevelopment/MZD-AIO/files/4081230/AIO_log.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/36#issuecomment-575922092) |
| [AIO_log-0.log](https://github.com/Trevelopment/MZD-AIO/files/4081231/AIO_log-0.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/36#issuecomment-575922092) |
| [gst-inspect.log](https://github.com/Trevelopment/MZD-AIO/files/4081232/gst-inspect.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/36#issuecomment-575922092) |
| [info.log](https://github.com/Trevelopment/MZD-AIO/files/4081233/info.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/36#issuecomment-575922092) |
| [AIO_log.log](https://github.com/Trevelopment/MZD-AIO/files/4289541/AIO_log.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/74#issuecomment-594817809) |
| [tweaks.txt](https://github.com/Trevelopment/MZD-AIO/files/4290431/tweaks.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/74#issuecomment-594977590) |
| [tweaks.txt](https://github.com/Trevelopment/MZD-AIO/files/4292288/tweaks.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/78#issuecomment-595142152) |
| [tweaks.txt](https://github.com/Trevelopment/MZD-AIO/files/4290431/tweaks.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/74#issuecomment-595413102) |
| [AIO_log.log](https://github.com/Trevelopment/MZD-AIO/files/4294877/AIO_log.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/74#issuecomment-595413102) |
| [AIO_log.log](https://github.com/Trevelopment/MZD-AIO/files/4300768/AIO_log.log) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/74#issuecomment-595994695) |
| [putty_log.txt](https://github.com/Trevelopment/MZD-AIO/files/7654687/putty_log.txt) | [Original](https://github.com/Trevelopment/MZD-AIO/issues/135#issuecomment-986093473) |
