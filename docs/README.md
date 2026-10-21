# MZD-AIO Web-Builder

Statische HTML/CSS/JavaScript-Anwendung fuer GitHub Pages. Keine Installation, kein Build-Schritt und keine externen Laufzeitabhaengigkeiten. `index.html` kann auch lokal geoeffnet werden.

## Funktionsumfang

- Festes Ziel: Firmware 74.00.324A EU.
- 41 Tweak-Eintraege aus der Offline-Pruefung vom 21.10.2026; drei interne Installer-Pruefbereiche sind keine Benutzeroptionen.
- Suche, Filter fuer Portierungskandidaten und Auswahl, Projektimport/-export als JSON.
- ZIP-Export mit vier originalen MP3-Triggern, Konsolenfenster und manuell gestartetem Vorpruefer. Keine Tweak-Installation.
- Verarbeitung ausschliesslich im Browser; keine Telemetrie, kein Upload und keine automatische Speicherung.

## Aufbau

- catalog.js: Katalog mit stabilen IDs, Auditbefund und Portierungsstatus.
- builder-core.js: Projektvalidierung, Import und ZIP-Erzeugung (STORE, UTF-8, CRC32).
- app.js: Bedienoberflaeche und Downloads; importierte Texte werden als Text ausgegeben.
- styles.css / index.html: responsives Layout ohne Framework.

`releaseStatus: unported` gilt fuer alle Eintraege. Ein Audit-Kandidat ist noch kein freigegebener Patch. Vor Einfuehrung installierbarer Pakete sind Payload-Manifest, Originalhashes, Sicherung, Ruecknahme und Fahrzeugbestaetigung umzusetzen. Der aktuelle Patcher laeuft ausschliesslich im Vorpruefmodus.

## Pruefung dieses Stands

JavaScript-Syntax, Modellvalidierung, JSON-Roundtrip, Ablehnung falscher Firmware/unbekannter Tweaks sowie Auswahl, Filter, Reset, Download und Importfehler im simulierten DOM geprueft. Erzeugtes ZIP unabhaengig mit Python zipfile auf CRC, UTF-8, Dateiliste und JSON-Inhalte geprueft. Kein visueller Test im echten Browser verfuegbar.

Veroeffentlichung: GitHub Pages aus `master/docs`.

## USB-Paket / bestaetigter Zugang mit Tastatur

ZIP vollstaendig in das Hauptverzeichnis eines FAT32-Sticks entpacken. mp3/a.mp3 (alternativ b/c/d fuer die Mountpunkte sdb1/sdc1/sdd1) abspielen, Konsole oeffnen, im OEM-Testmenue TERMINAL waehlen und auf die Shell warten. Mit USB-Tastatur `sh /mnt/sda1/mzd/start.sh` eingeben; Mountpunkt gegebenenfalls anpassen.

`start.sh` prueft UID, Firmware 74.00.324, Patch A, EU, die ausgewaehlten IDs und drei bekannte OEM-Dateihashes. Ergebnis liegt auf USB unter reports/<Zeit>-<PID>/preflight.txt. Rueckgabe 0: bekannte Dateistaende; 1: Voraussetzung fehlt; 2: OEM-Dateien weichen ab. Keine Watchdog-/Firewall-/SSH-Aenderungen, keine Remounts oder OEM-Schreibzugriffe. Es wird nichts installiert. Ein Dateihash-Treffer bestaetigt keine Tweak-Laufzeitkompatibilitaet.

Der Konsolenzugang ist vom Besitzer am Fahrzeug bestaetigt. Das neu zusammengestellte Paket wurde nur lokal getestet. Kein automatischer Shellstart, kein RAM-Hook.

Die MP3s stammen bytegleich vom zuvor eingelesenen Besitzer-USB. Sie laden js/run.js aus dem jeweiligen Mountpunkt. Verwandte Technik: https://github.com/naijamesz/mazda-connect-root-refactor . Es werden keine Schluessel oder persoenlichen Konfigurationen ausgeliefert.

Die Quellen liegen unter docs/usb. Nach Aenderungen `python web-tools/build-usb-assets.py` ausfuehren: usb-assets.js enthaelt diese Dateien eingebettet fuer netzwerkfreien ZIP-Export. Kein Fetch, CDN oder Server fuer die Paketgenerierung erforderlich. Manifest-SHA256 dienen der Nachpruefbarkeit; sie sind keine Signatur. MD5 wird fuer den Dateistandsvergleich verwendet, weil das Geraet dieses Werkzeug bereitstellt.

Tests: `node web-tools/test-web-builder.js` erzeugt ein ZIP in einem temporaeren Ordner und meldet seinen Pfad. Danach `python web-tools/test-usb-preflight.py --zip <Pfad>` ausfuehren. Der Shelltest verwendet ausschliesslich eine abgeaenderte Testkopie mit synthetischen Dateien und prueft Firmware-Abbrueche, Auswahlvalidierung, Hashabweichungen und unveraenderte Fixtures. Kein echter Fahrzeug-/Browser-Renderingtest.

## Ablage von Berichten und Logs

Verbindlich fuer den Starter und weitere Installationsschritte: Berichte, Logs und spaetere Sicherungen gehoeren auf das Medium mit dem gestarteten Paket, unabhaengig vom aktuellen Arbeitsverzeichnis und dessen Mountnamen. Keine automatische Ausweichablage im internen CMU-Speicher.

Der Starter bestimmt den USB-Pfad aus seinem eigenen Verzeichnis. Pro Lauf entsteht reports/<Zeit>-<PID>/ mit run.log (stdout und stderr ab Beginn der Pruefungen), status.txt (Exit-Code) und preflight.txt, wenn der Dateivergleich erreicht wird. Auch Root-/Firmware-/Auswahlfehler landen im run.log. Die Ausgabe wird am Ende zusaetzlich in der Konsole angezeigt. Ist das Startmedium nicht beschreibbar, erfolgt ein Abbruch vor den Pruefungen. Tests decken fruehe Fehler, einen anderen Arbeitsordner, Leerzeichen im USB-Pfad sowie ein blockiertes Berichtsverzeichnis ab.
