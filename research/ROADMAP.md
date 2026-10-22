# Arbeitsreihenfolge

Aktueller v74-Umfang: [REWORK-SCOPE.md](REWORK-SCOPE.md). Die dort ausgeschiedenen Alt-Tweaks sind keine offenen Aufgaben.

Diese Liste ist ein Arbeitsvorschlag aus der Recherche. Noch keine Umsetzung und kein CMU-Test.

## 1. Desktop-Basis reproduzierbar machen

- PR #230 isoliert prüfen: Start ohne Update-URL, fehlerhafte Übersetzung, Wi-Fi-AP-Paket.
- Externe Übersetzung/Updater dürfen Paketgenerierung offline nicht blockieren.
- Ressourcen-/Farbschema-Pfade pro Plattform normalisieren, fehlende Dateien vor Build anzeigen.
- Alle Shell-/Autorun-Dateien im fertigen Paket auf LF, passende Shebangs und Dateimodi prüfen.
- Ausgabe in einen normalen Ordner erlauben; USB-Erkennung davon unabhängig behandeln.
- PR #207 als Buildrezept-Spur nutzen, LABEL/FROM und alte Toolchain gesondert prüfen.
- Dependency-Modernisierung als zusammenhängende Toolchainmigration; alte Dependabot-Lockfiles nicht nacheinander blind übernehmen.

**Abnahme:** reproduzierbares Paket mit Dateiliste/Hashes, verständliche Fehler und kein Netzwerkzwang. Zunächst ein festgelegtes Desktop-Betriebssystem, weitere Plattformen danach.

## 2. Prüfgerät identifizieren und lesend inventarisieren

Vor jeder Firmware-/Tweakänderung Hardwarekennung, komplette Firmwareversion/Region, USB-Hub, Display und vorhandene Funktionen dokumentieren. Zielprofil ausdrücklich festlegen. Den MP3-/Diagnoseeinstieg zunächst ohne automatische AIO-Gesamtauswahl prüfen.

Erheben: `/jci/version.ini`, System-/Prozess-/Mountübersicht, freier Platz je Partition, verfügbare Shell-/BusyBox-/SSH-Werkzeuge, Symlinkziele und Schreibschutz. Dateiexport mit Modus, Eigentümer, Symlinkziel und SHA-256 versehen. Persönliche Kontakte, gekoppelten Geräte und Nutzerdaten nicht in das öffentliche Repository aufnehmen.

**Abnahme:** vollständiges Inventar der untersuchten Dateien mit Quelle und Hash; Export zweimal gegenprüfbar. Ein JCI-Export ist noch kein Brick-Recoveryimage.

## 3. Zugang und Wiederherstellung getrennt erproben

Minimalen SSH-Zugang entwerfen, ohne komplette historische Firewall-/Passwortdateien ungeprüft zu ersetzen. Netzwerkmodus bewusst wählen; WLAN-AP nicht automatisch erzwingen. Zugang über Reboot und Rückbau prüfen.

Bevor UI-Kerndateien verändert werden: Wiederherstellungsverfahren am Ersatzgerät und Zugriff nach einem kontrollierten Fehler nachweisen. Serielle Konsole nur als vorhandenen Kanal dokumentieren, nicht als garantierten Root-Zugang bezeichnen.

## 4. Patches einzeln portieren

Pro Tweak festhalten:

- Firmwareprofil und erwarteter Originalhash;
- genaue Zielstellen sowie Vorher-/Nachherdiff;
- gemeinsame Zielstellen/Konflikte mit anderen Tweaks;
- atomare Ersetzung, Sicherung und Abbruch bei unbekannter Datei;
- Idempotenz, Uninstall und erneute Installation;
- funktionaler Test mit Ergebnis und Logs.

Mit kleinen UI-Änderungen beginnen. Änderungen an `systemApp.js`, WLAN/OEM-CP und App-Lifecycle getrennt behandeln. Keine komplette v70-Datei als v74-Fix übernehmen.

## 5. Bedienung vereinfachen

Erst auf nachgewiesener Technik aufbauen: Paketerstellung, optionaler USB-Einstieg, SSH und eigentliche Tweaks als klar sichtbare Schritte. „Zugang möglich“ und „Tweak unterstützt“ getrennt anzeigen. Kompatibilität anhand konkreter Profile/Dateien erkennen; unbekannte Varianten bleiben als solche sichtbar.

## 6. Erweiterungen

Mögliche spätere Themen aus den Issues: Startlautstärke (#11), Autoplay abschalten (#147), Statusbar (#177), Datenanzeigen/externe Sensoren (#2/#39), HUD-Navigation (#87/#206/#224). Vor Entwicklung Datenverfügbarkeit und OEM-Konflikte nachweisen. Legacy-AA, Medienwiedergabe und Kamerawechsel sind eigene größere Vorhaben.

## Ergebnisprotokoll pro Versuch

Datum · CMU/Display/Hub · Firmware/Region · Ausgangshashes · Zugangsmethode · genau ein Tweak/Commit · beobachtetes Ergebnis · Reboot/Warmstart · Rückbau · Logs · Status: bestätigt / gescheitert / unklar.

Erst ein reproduzierter Nachweis ändert einen Matrixeintrag auf „am Prüfgerät bestätigt“.
