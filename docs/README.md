# MZD-AIO Web-Builder

Statische HTML/CSS/JavaScript-Anwendung fuer GitHub Pages. Keine Installation, kein Build-Schritt und keine externen Laufzeitabhaengigkeiten. `index.html` kann auch lokal geoeffnet werden.

## Funktionsumfang

- Festes Ziel: Firmware 74.00.324A EU.
- 41 Tweak-Eintraege aus der Offline-Pruefung vom 21.10.2026; drei interne Installer-Pruefbereiche sind keine Benutzeroptionen.
- Suche, Filter fuer Portierungskandidaten und Auswahl, Projektimport/-export als JSON.
- ZIP-Export als ausdruecklicher Projektentwurf mit project.json, patch-status.json und README.txt. Keine Installer oder Fahrzeug-Payloads.
- Verarbeitung ausschliesslich im Browser; keine Telemetrie, kein Upload und keine automatische Speicherung.

## Aufbau

- catalog.js: Katalog mit stabilen IDs, Auditbefund und Portierungsstatus.
- builder-core.js: Projektvalidierung, Import und ZIP-Erzeugung (STORE, UTF-8, CRC32).
- app.js: Bedienoberflaeche und Downloads; importierte Texte werden als Text ausgegeben.
- styles.css / index.html: responsives Layout ohne Framework.

`releaseStatus: unported` gilt fuer alle Eintraege. Ein Audit-Kandidat ist noch kein freigegebener Patch. Vor Einfuehrung installierbarer Pakete sind Payload-Manifest, Originalhashes, Sicherung, Ruecknahme und Fahrzeugbestaetigung umzusetzen. Der aktuelle ZIP-Export bleibt davon getrennt.

## Pruefung dieses Stands

JavaScript-Syntax, Modellvalidierung, JSON-Roundtrip, Ablehnung falscher Firmware/unbekannter Tweaks sowie Auswahl, Filter, Reset, Download und Importfehler im simulierten DOM geprueft. Erzeugtes ZIP unabhaengig mit Python zipfile auf CRC, UTF-8, Dateiliste und JSON-Inhalte geprueft. Kein visueller Test im echten Browser verfuegbar.

Veroeffentlichung: GitHub Pages aus `master/docs`.
