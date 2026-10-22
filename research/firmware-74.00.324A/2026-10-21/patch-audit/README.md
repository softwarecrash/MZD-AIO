# AIO-Patchprüfung: 74.00.324A EU

Statische Prüfung des Fork-Stands einschließlich lokaler Textproben. **Keine Freigabe für eine Installation auf der MCU.** Es wurden keine vollständigen Installer-/Uninstaller-Skripte und keine Fahrzeugbefehle ausgeführt.

## Ergebnis in Zahlen

- Alle 125 Skriptdateien stimmen per Git-Blob-SHA mit dem geprüften Fork überein.
- 41 Prüfbereiche bleiben in der Matrix; drei veraltete Bereiche stehen in `retired-features.json` und sind keine Portierungsaufgaben.
- 247 direkte `cp`-Anweisungen inventarisiert; 369 existierende Dateiziele über alle statisch auflösbaren Kopierzweige gefunden. Das sind keine 369 eindeutigen Dateien und keine Aussage darüber, welche Zweige zur Laufzeit laufen.
- 247 sed-Zielproben: 169 tatsächlich an lesbaren Originalen untersucht (36 verändern die Originaldatei, 133 nicht); 78 wegen fehlender Textfixture, Variablen oder nicht freigegebener Ausdrucksform nicht ausgeführt.
- Acht ausgewählte Textkomponenten: alle verändern ihre Zielstelle und bleiben bei zweiter, guard-modellierter Anwendung unverändert. Drei direkte Text-Rücknahmen liefern bytegenau das Original.
- 28 geänderte JavaScript-Fälle plus jeweiliges Original im modernen JavaScript-Parser geprüft; alle syntaktisch gültig. Das beweist keine Laufzeit-Kompatibilität mit Mazda Opera.

## Die wichtigsten Befunde

1. **Versionszuordnung zuerst reparieren.** Die originale Funktion liefert für 70.00.360 Gruppe 6, für 70.00.361 Gruppe 7 und für 74.00.324 Gruppe 0. Gruppe 0 wird regulär beendet. Wird nur dieser Abbruch entfernt, werden gleichzeitig alte `<5`-Zweige wie FLAC/USB Audio erreichbar. Ein neues `74` in der alten `70`-Bedingung genügt deshalb nicht als Kompatibilitätsnachweis.
2. **Keine pauschale systemApp-Ersetzung.** Die v70-App-Registrierungspayload verliert acht im v74-Original deklarierte Methoden, unter anderem Wireless-CarPlay-/Menühandler. Disclaimer und Audio-Reihenfolge bauen ebenfalls alte Gesamtdateien zusammen; diese `cat`-Wege sind manuell geprüft, nicht vollständig vom Kopierinventar erfasst.
3. **Diagnose-Tweak nur teilweise passend.** Die drei Timer-/Einstiegs-Textstellen sind nutzbare Portierungskandidaten. Das danach kopierte alte `TestCtrl.js` verliert jedoch `setUblox`.
4. **Multicontroller-Snippet nimmt sich selbst zurück.** Auf den Kopierblock folgt unbedingtes `restore_org /jci/gui/common/js/Multicontroller.js`. Bei erfolgreichem Original-Backup wird die kopierte Änderung sofort wieder überschrieben.
5. **Rollback auf echte v74-Originale begrenzen.** Die alte Integritätsfunktion verwendet v70-Fallbacks und Größenvergleiche; pauschales Zuordnen von v74 zu Gruppe 6 würde auch diese Logik aktivieren. `backup_org` verwendet außerdem nur den Basisnamen im Ressourcen-Backup und akzeptiert ein bereits existierendes neues Backup vor einer Inhalts-/Größenprüfung. Für v74 vollständigen Pfad plus Originalhash verwenden und bei fehlendem/leerem Backup abbrechen.
6. **Bild-Rücknahme ist teilweise unvollständig.** Bigger Album Art ersetzt Bilder, stellt sie im zugehörigen Uninstall aber nicht wieder her. Blank Album Frame und andere Grafik-Tweaks verwenden pauschale Altgrafiken als Rücknahme. Bilder genauso sichern wie JavaScript/CSS.
7. **Installer-Vorarbeiten sind Teil der Prüfung.** `00_start.txt` verändert Watchdogs, Opera-Konfiguration und Dateirechte, bevor einzelne Tweaks laufen. Das muss im v74-Installer separat behandelt und rücknehmbar sein.

## Matrix

`TEXT_KANDIDAT`/`CSS_KANDIDAT` bedeutet nur: geeigneter Ausgangspunkt für eine gezielte Portierung. `ANPASSEN`, `ASSET_PRUEFUNG` und `LAUFZEIT_OFFEN` enthalten konkrete offene Arbeiten. Kein Status bedeutet „am Fahrzeug bestätigt“.

| Prüfbereich | Ergebnis | Skripte | Befund |
|---|---|---|---|
| installer | ANPASSEN | `00_backup.txt`, `00_end.txt`, `00_factory-reset-end.txt`, `00_intro.txt`, `00_start.txt` | v74 ergibt Gruppe 0 und wird regulär beendet. Vorarbeiten verändern Watchdogs und Opera global; Backup- und Fehlerbehandlung für v74 neu prüfen. |
| full-restore | NICHT_UNVERAENDERT | `00___fullRestore.sh`, `99_self-destruct.txt` | Breite Wiederherstellung/Löschung und ältere Fallbacks. Kein v74-Rollback aus beliebigen mitgelieferten Altdateien ableiten. |
| legacy-app-registration | NICHT_UNVERAENDERT | `00_59patch.txt` | systemApp.70.js verliert gegenüber v74 acht deklarierte Methoden. Die 59er-Datei verliert 14. App-Einbindung als kleinen v74-Patch neu aufbauen. |
| background | ASSET_PRUEFUNG | `00_background.txt`, `00_offbackground-i.txt`, `00_offbackground-u.txt` | Bildziele vorhanden; Bildformat und echte Original-Backups je Ziel sichern. Kein Fahrzeug-/Renderingtest. |
| background-rotation | CSS_KANDIDAT | `00_bgrotator-i.txt`, `00_bgrotator-u.txt` | Ergänzt markiertes CSS. CSS-Marker und Rücknahme je Feature isolieren; Bild-/Animationsdarstellung ist offen. |
| multicontroller | NICHT_UNVERAENDERT | `00_multicontroller-i.txt` | Nach dem Kopieren steht am Ende ein unbedingtes restore_org desselben Multicontroller.js. Bei erfolgreichem Backup wird die Änderung sofort rückgängig gemacht. |
| reconnect-message | TEXT_KANDIDAT | `00_reconnectmsg-i.txt` | Zielstelle trifft; guard-modellierte zweite Anwendung bleibt unverändert, erzeugtes JavaScript ist syntaktisch gültig. Laufzeitsemantik des Dialogereignisses offen; kein eigenes -u-Skript. |
| sd-cid | LAUFZEIT_OFFEN | `00_sd-cid.txt` | Zusätzliches natives Hilfsprogramm; Architektur, Laufzeit und SD-Zustände nicht ausgeführt/geprüft. |
| ssh-bringback | NICHT_UNVERAENDERT | `00_sshbringback.txt` | Nicht nur Portfreigabe: kopiert alte Firewall-/SSH-Dateien und kann Herstellungs-/Kontenkonfiguration über weitere Skripte verändern. v74-WCP-Regeln erhalten; alte Variante nicht freigeben. |
| storage | LAUFZEIT_OFFEN | `00_storage-i.txt`, `00_storage-u.txt` | Opera-Persistenzdateien und Links sind zustandsabhängig. Kein Test der Browserdatenmigration oder Rücknahme vorhandener Daten. |
| wifi | LAUFZEIT_OFFEN | `00_wifi.txt` | Ändert Netzwerkkonfiguration; bestehende v74-/Wireless-CarPlay-Nutzung und Rücknahme nicht auf dem Gerät geprüft. |
| aio-app | LAUFZEIT_OFFEN | `00__aioapp.txt`, `27_aioapp-i.txt`, `27_aioapp-screenoff.txt`, `27_aioapp-u.txt` | Benötigt zusätzliche Apps, UserJS und Startintegration. Dateipfade allein beweisen keine funktionierende v74-App-Laufzeit. |
| casdk-node | ANPASSEN | `00__casdk-i.txt`, `00__casdk-u.txt`, `00__casdkapps-i.txt`, `00__casdkapps-u.txt`, `00__node-i.txt` | Startskripte, Proxys, Ressourcen und App-Liste. Alte systemApp-Ersetzungen verlieren v74-Methoden; neue Integration und native Abhängigkeiten getrennt prüfen. |
| touchscreen | ANPASSEN | `01_touchscreen-i.txt`, `01_touchscreen-u.txt` | Common.js-Textkomponente trifft, ist guard-modelliert idempotent und per direktem Uninstall-sed bytegenau rücknehmbar. Zusätzlich verändern die OEM-Helfer NVRAM-/LVDS-Zustände; diese und DVD-D-Bus wurden nicht getestet. |
| disclaimer | NICHT_UNVERAENDERT | `02_disclaimer-i.txt`, `02_disclaimer-u.txt` | Verwendet vollständige ältere systemApp-Dateien bzw. cat-Zusammenbau. v74-WCP-/Menülogik erhalten; als gezielten Patch neu implementieren. |
| camera-warning | ASSET_PRUEFUNG | `03_warning-i.txt`, `03_warning-u.txt` | Ersetzt Bilder; Installationssnippet besitzt keine backup_org-Aufrufe. Für v74 reale Bild-Originale statt pauschaler Altgrafiken zurückspielen. |
| parking-sensors | ASSET_PRUEFUNG | `04_sensor-i.txt`, `04_sensor-u.txt` | Ersetzt Gruppen von Bildern; keine individuellen Original-Backups im Installationssnippet. Grafikformate, Sensorvarianten und Rücknahme offen. |
| main-menu-loop | ANPASSEN | `05_mainloop-i.txt`, `05_mainloop-u.txt` | v74-MainMenuCtrl.js ist bytegleich zur AIO-v70-Vorlage. Kopierte Tweakdatei entfernt keine erkannten OEM-Methoden; trotzdem komplette Ersetzung und Gruppenbedingung <=7 durch hashgebundenen v74-Patch ersetzen. |
| list-loop | ANPASSEN | `06_listloop-i.txt`, `06_listloop-u.txt` | v74-List2Ctrl.js ist bytegleich zur v70-Vorlage; alte Auswahl <=6 und Wechselwirkung mit Delay-Mod beachten. Gesamtdateiersetzung nicht pauschal freigeben. |
| list-beep | TEXT_KANDIDAT | `07_listbeep-i.txt`, `07_listbeep-u.txt` | Textänderung trifft, ist wiederholbar ohne weitere Änderung und mit den direkten Uninstall-Ausdrücken bytegenau rücknehmbar. JavaScript-Syntax geprüft; Fahrzeugtest offen. |
| shorter-delay | TEXT_KANDIDAT | `07_shorterdelay-i.txt`, `07_shorterdelay-u.txt` | Vier Zeitparameter und Markierung wurden gemeinsam offline angewendet. Zweite Anwendung identisch; direkte Text-Rücknahme ergibt exakt das Original; JavaScript-Syntax geprüft. |
| system-beep | TEXT_KANDIDAT | `08_sysbeep-i.txt`, `08_sysbeep-u.txt` | Die system/PlayAudioBeep-Zielstelle trifft, audiosettings-Alternative trifft nicht und ist eine alternative Verzweigung. Markierungs-Guard ist idempotent; Syntax geprüft. Kompletter Uninstall noch nicht simuliert. |
| audio-source-order | NICHT_UNVERAENDERT | `09_audioorder-i.txt`, `09_audioorder-u.txt` | cat-Zusammenbau ersetzt systemApp aus 59/70-Vorlagen, einschließlich kombinierter Disclaimer-Varianten. Neue WCP-Einträge und Ereignisse müssen erhalten bleiben. |
| message-replies | ANPASSEN | `11_msgreplies-i.txt`, `11_msgreplies-u.txt` | Ersetzt Konfigurations-XML und verlangt Factory Reset; entfernt ggf. input_filter aus sm.conf ohne backup_org für sm.conf in diesem Snippet. Einstellungs-/Datenreset ist kein durch Text-Rollback vollständig rücknehmbarer Schritt. |
| diagnostic-entry | ANPASSEN | `12_diag-i.txt`, `12_diag-u.txt` | Die drei kleinen Eingriffsstellen treffen und sind guard-modelliert idempotent/syntaktisch gültig. Anschließendes Kopieren der alten Test-Steuerelemente entfernt aber setUblox aus dem v74-TestCtrl.js. |
| boot-animation | ASSET_PRUEFUNG | `13_boot-i.txt`, `13_boot-u.txt` | Variantenabhängige IVF-Dateiersetzungen mit Loop-/Transition-Zielen; Dateien vorhanden, Decoder-/Auflösungsprüfung und Fahrzeugstarttest nicht ausgeführt. |
| bigger-album-art | ANPASSEN | `14_bgart-i.txt`, `14_bgart-u.txt` | CSS wird ergänzt; zwei Rahmenbilder werden zusätzlich ersetzt. Uninstall entfernt primär CSS und stellt diese Bilder nicht wieder her; Image-Backups/Rücknahme ergänzen. |
| button-backgrounds | CSS_KANDIDAT | `15_btnbackground-i.txt`, `15_btnbackground-u.txt` | Markiertes CSS in Ump3Ctrl.css; Optionen und gemeinsame Marker mit anderen UI-Tweaks müssen kombiniert getestet werden. Keine UI-Renderingprüfung. |
| blank-art-frame | ASSET_PRUEFUNG | `16_blnkframe-i.txt`, `16_blnkframe-u.txt` | Drei Bilddateien werden ersetzt, Uninstall kopiert mitgelieferte config_org-Grafiken statt geräteeigener Backups. Hashgebundene Originale je Datei erforderlich. |
| video-player | LAUFZEIT_OFFEN | `17_videoplayer-i.txt`, `17_videoplayer-u.txt` | Startet websocketd mit Shell und installiert GStreamer-/FLAC-Bibliotheken. ABI, Netzwerkzugriff, Player und Bibliotheksabhängigkeiten nicht ausgeführt. |
| swapfile | LAUFZEIT_OFFEN | `18_swapfile-i.txt`, `18_swapfile-u.txt`, `18_swapfile2-i.txt` | Benötigt USB-Speicher-/Dateisystem-/Swap-Zustände und Startintegration. Diese Eigenschaften lassen sich aus den Firmwaredateien nicht freigeben. |
| speedometer | LAUFZEIT_OFFEN | `19_sbfuelbar.txt`, `19_speedo-analog.txt`, `19_speedo-digiclock.txt`, `19_speedo-dutch.txt`, `19_speedo-english.txt`, `19_speedo-french.txt`, `19_speedo-i1.txt`, `19_speedo-i2.txt`, `19_speedo-italian.txt`, `19_speedo-kml.txt`, `19_speedo-lrgtxt.txt`, `19_speedo-mph.txt`, `19_speedo-old_background.txt`, `19_speedo-own_background.txt`, `19_speedo-polish.txt`, `19_speedo-sbdonthide.txt`, `19_speedo-sbhiderev.txt`, `19_speedo-slovak.txt`, `19_speedo-small_speedo_off.txt`, `19_speedo-spanish.txt`, `19_speedo-temp.txt`, `19_speedo-turkish.txt`, `19_speedo-u.txt`, `19_speedo_bar.txt` | Gemeinsamer Prüfbereich einschließlich Sprach-/Anzeigeoptionen: installiert App und Websocket-/Shell-Startpfad; Fahrzeugdatenquellen und vollständige Optionen-Laufzeit offen. |
| date-statusbar | ANPASSEN | `20_date-iv1.txt`, `20_date-iv3.3.txt`, `20_date-u.txt`, `20_date2status-u.txt` | Ersetzt StatusBarCtrl.js/Utility.js mit Altvorlagen. v1 entfernt sechs erkannte OEM-Methoden; v3 behält Methodennamen, kann aber veränderte CP/AA-Methodenkörper überschreiben. Sicherer v74-Eingriff muss kleiner werden. |
| main-menu-style | CSS_KANDIDAT | `20_mainmenu-i.txt`, `20_mainmenu-u.txt` | Markierte CSS-Ergänzungen; v74-MainMenu-CSS ist bytegleich zur v70-Vorlage. Varianten, benutzerdefinierte Farben und Kombinationen visuell prüfen. |
| statusbar-style | CSS_KANDIDAT | `20_statusbar_tweaks-i.txt`, `20_statusbar_tweaks-u.txt` | Farb-/Transparenz-CSS wird ergänzt. Generische MZD-AIO-TI-CSS-Marker sind mit anderen CSS-Tweaks geteilt; Rücknahme und Reihenfolge isolieren. |
| ui-style | CSS_KANDIDAT | `20_uistyle-i.txt`, `20_uistyle-u.txt` | CSS-Ergänzungen und Löschen bestimmter Animationsregeln. Keine pauschale Ersetzung erforderlich, aber Selektoren/Kombinationen und UI-Wirkung offen. |
| colors-theme | ASSET_PRUEFUNG | `21_colors-i.txt`, `21_colors-i1.txt`, `21_colors-i2.txt`, `21_colors-u.txt`, `21_theme-i.txt` | Kopiert ganze themenabhängige jci-Bäume und ggf. Navigations-UX-ZIP. Gewählte Payloads und überschriebenen Umfang vor Generierung vollständig begrenzen und sichern. |
| fuel-consumption | ANPASSEN | `22_fuel-i.txt`, `22_fuel-u.txt`, `22_fuelMPG-i.txt` | JS/CSS der v74-Verbrauchsanzeige sind bytegleich zu AIO-v70. Die Tweak-Payload entfernt keine erkannten Methoden, ersetzt aber ganze Dateien und Bild; Einheiten und Sicherung aller drei Ziele gezielt portieren. |
| castscreen | LAUFZEIT_OFFEN | `24_castscreen-i.txt`, `24_castscreen-u.txt` | Native Empfangs-/Startprogramme und ggf. Bibliotheken; ABI, Smartphone-/USB-Verbindung und Laufzeit nicht getestet. |
| legacy-android-auto | LAUFZEIT_OFFEN | `25_androidauto-i.txt`, `25_androidauto-u.txt`, `25_androidautob-i.txt`, `25_androidautocargps.txt`, `25_androidautohud-i.txt`, `25_androidautorevgps.txt`, `25_androidautowifi-i.txt` | Alte headunit-/Audio-/Startintegration zusätzlich zur vorhandenen OEM-AA-Implementierung. Keine Laufzeit-/Audio-/USB-Freigabe allein aus Dateiproben ableiten. |
| mzd-meter | LAUFZEIT_OFFEN | `28_mzdmeter-i.txt`, `28_mzdmeter-u.txt` | Zusätzliche App, native Dateien und watch-/Shell-Startpfad; Schnittstellen und Laufzeit noch nicht validiert. |

## Reproduzierbare Belege

- `summary.json`: Umfang, Fork-Commit und Grenzen der automatisierten Proben.
- `script-inventory.json`: Alle Skripte mit Blob-SHA, Zeilenangaben, Versionsprüfungen, Backup-/Restore-Aufrufen.
- `sed-probes.json`: Quellzeile, Ausdruck, Ziel und Vorher-/Nachherhash jeder Probe.
- `copy-overwrites.json`: Statisch aufgelöste Payload-Ersetzungen und dabei fehlende deklarierte OEM-Methoden. Das ist ein Indikator, kein vollständiger semantischer Diff.
- `component-checks.json`: Acht ausdrücklich begrenzte Textkomponenten, Wiederholungs- und drei Text-Rücknahmetests.
- `version-checks.json`: Ausführung ausschließlich der originalen Versionsfunktion an lokalen synthetischen Versionsdateien.
- `javascript-syntax.json`: Syntaktische Prüfung, ausdrücklich kein Gerätesimulator.
- `feature-matrix.json`: Maschinenlesbare Zuordnung der verbleibenden Bereiche; ausgeschiedene Bereiche in `retired-features.json`.

## Grenzen und nächste Umsetzung

Die automatisierte Inventarisierung analysiert direkte sed/cp-Zeilen. Dynamische Variablen, alle Shell-Verzweigungen, heredocs, cat-Zusammenbau, weitere Hilfsskripte und sämtliche Optionen werden damit nicht vollständig ausgeführt oder bewiesen. Insbesondere ist ein sed-No-op auf einer unveränderten Datei häufig eine erwartete Cleanup-/Alternativverzweigung und allein kein Fehler.

Die sed-Proben verwenden GNU sed mit exakten Ausdrucksdateien und Daten über stdin/stdout. Nur eine kleine, I/O-freie Befehlsmenge ist zugelassen. Es findet kein `sed -i` auf den Sicherungen statt. BusyBox-spezifische Details und Opera-Laufzeit müssen später zusätzlich geprüft werden.

Als nächste Implementierung bieten sich eine eigene v74-Kompatibilitätsgruppe, pfad- und hashgebundene Backups sowie kleine, explizite Patches für Listenpiepsen und Listendelay an. Erst danach vollständige Installations-/Rücknahmeabläufe auf einem isolierten Dateibaum testen und einen getrennten Fahrzeugtest planen.

## Bereinigung am 22.10.2026

Die drei veralteten Tweaks sind aus der Arbeitsmatrix entfernt; verbindlicher Umfang: [REWORK-SCOPE.md](../../../REWORK-SCOPE.md). Historische Rohbefunde bleiben als Referenz erhalten.
