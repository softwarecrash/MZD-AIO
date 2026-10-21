# MZD-AIO Web-Builder / 74.00.324A EU

Statische HTML/CSS/JavaScript-Anwendung ohne Build-Schritt und ohne externe Browser-Abhaengigkeiten. Funktioniert auch beim lokalen Oeffnen von index.html. Keine Telemetrie, kein Upload.

## Bedienung wie bei AIO

- Pruefen / Auswahl planen: 41 Funktionsgruppen durchsuchen und Projekte als JSON speichern/oeffnen; keine Systemdateiaenderung.
- Installieren / Install: derzeit nur Listenpiepsen deaktivieren. Experimentell, offline geprueft, Fahrzeugtest offen.
- Deinstallieren / Uninstall: den ausgewaehlten portierten Tweak entfernen.
- Full System Restore: alle von diesem Rework unterstuetzten Systemdateien aus internen Originalen wiederherstellen, unabhaengig von der Auswahl. Derzeit List2Ctrl.js. Kein Werksreset und keine pauschale Ruecknahme fremder/alter AIO-Installationen.
- Apps To Resources: Standard fuer kuenftige neue Apps. Bestehende Systemdateien bleiben an ihrem Originalpfad. Noch keine Zusatz-App portiert.

Die 41 Gruppen fassen Install-/Uninstall-Snippets, Sprachen und Anzeigevarianten der 125 alten Skriptdateien zusammen. Drei interne Pruefbereiche sind keine Tweaks. Noch nicht portierte Tweaks sind nur im Pruef-/Planungsmodus auswaehlbar.

## USB-Start mit Tastatur

1. ZIP ins Hauptverzeichnis eines FAT32-Sticks entpacken.
2. USB-Audio: mp3/a.mp3 abspielen; alternativ b/c/d fuer andere Mountpunkte.
3. Konsole oeffnen, im OEM-Testmenue TERMINAL waehlen, auf die Shell warten.
4. `sh /mnt/sda1/tweaks.sh` eingeben. Ggf. sdb1/sdc1/sdd1 verwenden.
5. Vor Aenderungen mit j und Enter bestaetigen; sonst Abbruch. Nach Erfolg CMU selbst neu starten.

`sh /mnt/sda1/restore.sh` startet ebenfalls Full System Restore, ignoriert dabei Aktion und Auswahl im Paket. Ein neuer Stick genuegt; die Originale liegen intern auf der CMU.

Der MP3-Konsolenzugang mit Tastatur ist vom Besitzer bestaetigt. Das neue Installerpaket ist noch nicht am Fahrzeug bestaetigt. Keine RAM-Hooks, SSH-Aktivierung oder automatische Watchdog-/Opera-/Berechtigungsaenderung. Alte Anleitungen sind kein Firmware-Kompatibilitaetsnachweis.

## Sicherungen

Originale liegen intern unter `/resources/aio-rework/backups/74.00.324A-EU/<vollstaendiger Systempfad>.backup/` mit original und metadata.txt. Neue Sicherungen werden separat vorbereitet, geprueft und dann uebernommen. Vorhandene Originale werden nicht ueberschrieben. Beschaedigte oder unpassende Sicherungen fuehren zum Abbruch.

Eine zweite gepruefte Kopie liegt unter backups/ auf dem Start-USB. Vor dem Dateieingriff muessen beide Kopien passen. USB-Kopien uebernehmen keine Unix-Rechte: FAT32 stellt sie nicht dar. Interne Sicherungen erhalten die Attribute. Keine mitgelieferten alten Ersatzdateien.

Original und installierter Zustand werden per Hash erkannt. Unbekannte Dateien werden nicht ueberschrieben. Ergebnisse werden neben dem Ziel vorbereitet und geprueft, dann per rename uebernommen. Bei fehlgeschlagener Nachpruefung folgt die automatische Ruecknahme zum vorherigen Dateistand. Das ist kein Nachweis fuer Stromausfallsicherheit von relfs.

## Logs immer auf dem Startmedium

Pro Lauf entsteht reports/<Zeit>-<PID>/ mit run.log (stdout/stderr, auch fruehe Fehler), summary.txt (lesbares Ergebnis), status.txt (Exit-Code) und ggf. platform.md5, preflight.txt und before.js. Der Ort folgt dem Paketpfad, unabhaengig vom Arbeitsverzeichnis. Keine interne Ausweichablage fuer Logs.

Ein schreibgeschuetzt eingebundener Start-USB wird fuer Berichte beschreibbar eingebunden. Ist das unmoeglich, folgt ein Abbruch. Nur benoetigte interne Partitionen werden fuer Sicherung/Dateiwechsel beschreibbar eingebunden; ihr vorheriger ro-Zustand wird beim Abschluss wiederhergestellt. Eine Sperre unter /tmp verhindert parallele Installer. SIGKILL oder Stromverlust koennen die Abschlussroutine verhindern.

## Entwicklung und Quellen

catalog.js enthaelt die 41 Gruppen. Listenpiepsen ist experimental, die uebrigen sind unported. builder-core.js validiert Projekte/Aktionen und erzeugt ZIPs mit binaeren MP3s. app.js, index.html und styles.css bilden die Oberflaeche. usb/ enthaelt alle Paketquellen.

Die MP3s stammen bytegleich vom zuvor eingelesenen Besitzer-USB. Verwandte Technik: https://github.com/naijamesz/mazda-connect-root-refactor . Keine Schluessel oder persoenlichen Konfigurationen.

Nach USB-Aenderungen: `python web-tools/build-usb-assets.py`. usb-assets.js ist generiert, damit der Browser ohne Fetch/CDN/Server exportieren kann. SHA256 im Manifest dienen der Nachpruefbarkeit, nicht als Signatur. Die CMU-Dateistandspruefung verwendet das vorhandene md5sum.

Tests: `node web-tools/test-web-builder.js` erzeugt ein temporaeres ZIP und meldet den Pfad. Dann:

```text
python web-tools/test-usb-installer.py --zip <ZIP> --original <gesicherte-v74-List2Ctrl.js>
```

Die Shelltests verwenden nur Testkopien mit ersetzten Geraetepfaden und gemockten mount/df/sync. Geprueft werden Install/Uninstall, Full System Restore von neuem Stick, Wiederholung, Defekte, Abbruchfaelle und USB-Logs. Keine realen Mounts oder Fahrzeugzugriffe. Kein visueller Browsertest verfuegbar.

Veroeffentlichung: GitHub Pages aus master/docs. Webentwicklung in web/html-js-builder.
