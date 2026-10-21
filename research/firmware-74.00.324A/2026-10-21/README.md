# Firmware 74.00.324A EU: Arbeitsstand vom 21.10.2026

Dieser Tagesordner enthält die heutige Geräteauslesung, Analyse und den vorbereiteten USB-Test für den Rework von MZD-AIO. Die bestehende Anwendung und die bisherigen Installerdateien werden durch diesen Commit nicht geändert.

## Stand

- Vom eigenen Gerät bestätigt: `MAZ_CMU-150_74.00.324`, Patch `A`, Flavor `cmu150_EU`, Linux 3.0.35 ARMv7.
- `/jci` vollständig gesichert: 6.600 Archiveinträge, 301.633.694 Bytes Dateiinhalte. Zusätzlich `/etc`, Programme, Bibliotheken, Konfigurationen, interne Daten, Laufzeitdateien und kleine Ressourcen.
- Alle sechs Hauptarchive wurden gelesen, auf gzip-Integrität geprüft und mit SHA-256 erfasst. Neun zentrale Dateien stimmen zusätzlich mit direkt auf der MCU berechneten Prüfsummen überein.
- Zwölf begrenzte Boot-/Flash-Leseabbilder wurden mit erwarteter Länge und Prüfsummen gesichert. Ergänzende interne Laufzeitdatenbank, Inventar und Diagnoseausgaben sind vorhanden.
- Die großen NATP-Sprachressourcen und die Gracenote-Musikdatenbank wurden auf Wunsch ausgelassen. Das ist eine Dateisicherung eines laufenden Systems, kein atomisches vollständiges Flash-Image.
- 24 gezielt zugeordnete Textdateien wurden mit den in AIO enthaltenen v70-Vorlagen verglichen; 15 unterscheiden sich. Unterschiede allein beweisen weder Kompatibilität noch Inkompatibilität einzelner Patches.
- Der USB-Test wurde lokal auf Shell-Syntax und JavaScript-Ablauf geprüft, aber noch nicht am Fahrzeug ausgeführt. Ein tastaturloser USB-Kaltstart ist noch nicht gelöst.

## Patchpruefung

Die [Offline-Pruefung aller 125 AIO-Skripte](patch-audit/README.md) dokumentiert 44 Pruefbereiche, konkrete v74-Konflikte und begrenzte lokale Texttests. Es besteht noch keine Freigabe fuer die Installation am Fahrzeug.

## Inhalt

| Ordner | Inhalt |
|---|---|
| `evidence/` | Bereinigter Lesebericht, AIO-Zielpfade, v70-Diffs und Konsolenbefunde |
| `tools/` | Relevante Auslese- und Analysewerkzeuge |
| `usb-test/` | Vorbereiteter, ausdrücklich experimenteller MP3-/Terminal-/SSH-Test |
| `firmware-reference/` | Gezielt ausgewählte v74-Originaldateien für AIO-Patches, Vergleiche und Konsolenstart; mit Prüfsummen |

Die lesbaren Dateien verwenden eine Beispiel-IP aus `192.0.2.0/24` und `PATH_TO_PRIVATE_KEY` anstelle der Notebook-Konfiguration. Die Tools sind der dokumentierte Forschungsstand und müssen vor einer Wiederverwendung auf die lokale Umgebung eingestellt werden. Es wird noch kein neuer kompatibler AIO-Installer ausgeliefert.

## Umfang der Veröffentlichung

Auf Benutzerwunsch werden ausschließlich die für den MZD-AIO-Rework relevanten Unterlagen hochgeladen. Die vollständige Gerätesicherung, private Schlüssel, benutzerspezifische öffentliche Schlüssel, Konten-/WLAN-Daten, persönliche Konfigurationen, Datenbanken, Rohprotokolle und Bootabbilder bleiben lokal. Es wird auch kein verschlüsselter Gesamt-Workspace hochgeladen.

`firmware-reference/manifest.json` dokumentiert Auswahl, Größen und SHA-256 der ausgewählten Originaldateien. Die Auswahl umfasst vorhandene wörtliche AIO-Dateiziele, die v70-Vergleichsdateien und die relevanten Konsolen-Startpfade. Sie ist keine vollständige Firmwaredistribution. Variabel zusammengesetzte Patchpfade und bislang unbekannte Abhängigkeiten müssen im weiteren Rework anhand der lokalen Originalarchive geprüft werden.

Der lesbare Lesebericht und einige Analysewerkzeuge verweisen auf die lokalen Archivnamen. Diese Archive sind bewusst nicht Bestandteil des Branches. Der bisher heruntergeladene AIO-Referenzbaum wird ebenfalls nicht dupliziert; dessen Herkunft ist unten festgehalten.

## Konsolenbefund und USB-Test

Der vorhandene MP3-Auslöser lädt JavaScript und fordert über die GUI Diagnose-Test `11` an. Das originale `/jci/scripts/startSystemScripts.sh` öffnet dafür `jci-systemDialog`. Dessen Terminalfunktion ruft über `systemHooks.sh` die Aktion `22` und `run-terminal.sh` auf. Das Original startet fest `/usr/bin/terminal -f`; zusätzliche USB-Befehle werden nicht weitergereicht.

Am gesicherten Terminal wurde `--shell` als ausführbarer Programm-/Skriptpfad bestätigt. Es verwendet `execl(path, path, NULL)` und zerlegt keine zusätzliche Befehlszeile. Der vorbereitete Test verwendet deshalb ein ausführbares Einstiegsskript und einen optionalen temporären Bind-Mount über den Diagnose-Startpfad. Die einmalige Einrichtung benötigt weiterhin eine funktionierende Root-Konsole oder SSH. Der Hook verschwindet beim Neustart.

Der Test startet einen separaten schlüsselbasierten SSH-Server auf Port `2223`, damit der zuvor verwendete Port `2222` keinen falschen Erfolg ergibt. Für eine Wiederverwendung muss der eigene öffentliche Schlüssel als `mazda.pub` sowohl ins USB-Hauptverzeichnis als auch nach `keyboardless/` gelegt werden; benutzerspezifische Schlüssel sind in der öffentlichen Kopie ausgelassen. Das vollständige ursprüngliche Paket bleibt lokal erhalten.

## Nächste Rework-Schritte

1. Firmware-Erkennung und Kompatibilitätsgruppen für exakt geprüfte v74-Stände ergänzen.
2. Patchziel und erwarteten Originalzustand je Tweak prüfen; unerwartete Dateien ablehnen.
3. Änderungen auf den jeweiligen v74-Originaldateien aufbauen, insbesondere keine pauschalen v70-Dateiersetzungen übernehmen.
4. Backup, Abbruch bei Fehlern und Rücknahme vor einem Fahrzeugtest durchgängig prüfen.
5. Den USB-Kaltstart gesondert untersuchen; den experimentellen RAM-Hook nicht als gelösten Kaltstart ausgeben.

Referenz für die AIO-Vergleiche: [Trevelopment/MZD-AIO](https://github.com/Trevelopment/MZD-AIO), Commit `409c724ed860497b2a34f9367cb4a019287846ea`. Grundlage der Gerätebefunde sind die in dieser Sitzung erstellten Sicherungen des eigenen Geräts.

## Erster ausfuehrbarer Patch

[Listenpiepsen fuer v74](patches/list-beep/README.md) ist mit automatischer interner Originalsicherung, USB-Kopie, Uninstall und Full System Restore implementiert. 21 isolierte Integrationslaeufe bestanden; experimentell, Fahrzeugtest offen. Die Implementierung des Web-Branches ist im Manifest fest verlinkt.

## Kombinierbare List2-Patches

[Gemeinsame Dateiverwaltung fuer Listenpiepsen und Listendelay](patches/shared-list2/README.md): Original plus aktive Patchliste, getrennter Uninstall, Wiederanlauf nach unterbrochenem Vorgang. 31 isolierte Integrationslaeufe bestanden; Fahrzeugtest offen. Der Builder gruppiert die 41 Funktionsgruppen nach Bedienung, Oberflaeche, Apps und System.
