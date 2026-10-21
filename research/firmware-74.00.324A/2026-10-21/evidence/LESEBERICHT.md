# Mazda-CMU: Sicherung und erste Analyse

Stand: 2026-10-21T20:55:10 (Notebook-Ortszeit). Status: Lesejobs beendet; Exitcodes und Warnungen prüfen.

## Gerät und Umfang

- SSH: `cmu@192.0.2.1:2222`, Benutzer `cmu` mit UID 0.
- Firmware laut `/jci/version.ini`: `MAZ_CMU-150_74.00.324`, Patch `A`, Flavor `cmu150_EU`.
- Linux 3.0.35, ARMv7. Die Geräteuhr steht auf Januar 1970; die Ordnerzeit stammt vom Notebook.
- Root-Dateisystem und interne Ressourcen sind bereits nur lesbar gemountet. Keine Remounts, Patches, Neustarts, Dienständerungen oder Installationen auf der MCU vorgenommen.
- Dateiarchive erhalten Unix-Metadaten und Symlinks. Keine Symlinks rekursiv verfolgen. USB `/tmp/mnt/sda1` wird nicht kopiert.
- `/proc`, `/sys`, `/dev` werden nicht rekursiv gelesen. Ausgewählte Systeminformationen werden separat erfasst.
- Es gibt kein `/boot`. Updatebestandteile liegen u. a. unter `/jci/reflash`. Nach den Systemdateien werden zusätzlich ausdrücklich begrenzte Lesezugriffe auf kleine Boot-/Flash-Geräte ausgeführt; kein Schreiben auf Blockgeräte.

## Downloadstatus

| Archiv | Komprimierte Größe | Einträge | Integrität | SSH-Exit |
|---|---:|---:|---|---:|
| 01_aio_console_priority | 32.92 MiB | 5477 | OK | 0 |
| 02_jci_complete | 136.05 MiB | 6600 | OK | 0 |
| 03_root_system | 51.85 MiB | 3525 | OK | 0 |
| 04_persistent_data | 10.38 MiB | 600 | OK | 0 |
| 05_resources_small | 0.64 MiB | 37 | OK | 0 |
| 06_runtime | 0.35 MiB | 520 | OK | 0 |

Boot-/Flash-Teilabbilder: 12 gelesen, 12 mit korrekter Länge und geprüfter gzip-Integrität. Details in `boot_partition_reads/manifest.json`.

Auf Benutzerwunsch werden die großen Ressourcenverzeichnisse `/resources/natp` (Sprachverarbeitung) und `/resources/gracenotedb` (Musikdatenbank) ausgelassen. Die zugehörigen Programme und Konfigurationen unter `/jci` sind bereits gesichert.

`manifest.json` enthält SHA-256, Mitgliederzahl, Größen und den ausgeführten Lesebefehl je Hauptarchiv. `.files.tsv` enthält die Unix-Pfade und Linkziele. `.stderr.txt` hält Warnungen und Lesefehler fest. Erst Archive ohne `.partial` und mit gültigem Manifest sind bestätigt. Ein gültiges Archiv allein garantiert bei einem SSH-Exit ungleich 0 nicht die vollständige Erfassung aller angefragten Dateien.

Geplante Reihenfolge: AIO-/Konsolenkern → `/jci` vollständig → übriges Rootsystem samt `/etc`, Programmen und Bibliotheken → interne Datenpartitionen → interne Ressourcen → temporäre Dateien und Protokolle → zusätzliche interne Laufzeitdatenbank. Der ergänzende Boot-Lesejob beginnt nach dem Rootsystem.

## Konsole und Befehle ohne Tastatur

Gesicherte Originaldateien liefern folgende Belege:

1. `/jci/scripts/systemHooks.sh`, Aktion `22` (`SYSTEM_TERMINAL`), ruft `/jci/scripts/run-terminal.sh` auf. Das Programm `/jci/tools/jci-systemDialog` enthält die Schaltfläche `TERMINAL` und den Aufruf `/jci/scripts/systemHooks.sh %d`.
2. `run-terminal.sh` setzt `XDG_RUNTIME_DIR=/tmp`, `XDG_CONFIG_HOME=/tmp/root/` und `SHELL=/bin/sh`, lädt `usbhid`, legt eine leere Weston-Konfiguration an und startet `/usr/bin/terminal -f`. Anschließend setzt `ivi-shell` Fokus, Z-Ebene und Deckkraft für `Wayland Terminal`.
3. Das Originalskript leitet keine eigenen Argumente an das Terminal weiter. Ein angehängter Befehl an `run-terminal.sh` wird somit nicht ausgeführt.
4. Am gesicherten ARM-Programm sind die Optionen `fullscreen` (`-f`) und `shell` (`--shell`) nachgewiesen. Die `shell`-Option ist ein einzelner Programm-/Skriptpfad. Der Aufruf bei Adresse `0xde1c` verwendet `execl(path, path, NULL)`; es findet dort keine Zerlegung einer Befehlszeile statt. Disassemblierung und Optionstabelle liegen unter `console_analysis/`.
5. Daraus folgt als statisch belegter Ansatz: ein ausführbares Skript per `terminal -f --shell=/voller/pfad/skript.sh` starten. Die eigentlichen Befehle stehen im Skript; eine Zeichenkette wie `--shell="/bin/sh -c ..."` ist dafür ungeeignet. Dieser Ansatz wurde nicht auf der MCU ausgeführt. Der unveränderte Menüstart startet weiterhin die normale Shell; das automatische Starten eines USB-Skripts aus genau diesem Menü ist damit noch nicht gelöst.
6. Befehle direkt über SSH benötigen bereits jetzt keine Tastatur am Fahrzeug; Remote-Kommandos wurden mit `id` und `uname` erfolgreich ausgeführt.
7. Die serielle Linux-Konsole ist laut Kernelparameter `ttymxc1,115200`. `/usr/bin/rungetty` startet `getty` auf `/dev/console` mit 115200 Baud und `/usr/bin/runlogin`; das ist ein separater Weg zum Bildschirmterminal.

Zum Zeitpunkt der Aufnahme liefen bereits `/usr/bin/terminal -f` (PID 9952), dessen `/bin/sh` (PID 9960) und `jci-systemDialog`. Es wurde keine weitere Bildschirmkonsole gestartet.

## Grundlage für MZD-AIO

Referenz: [Trevelopment/MZD-AIO](https://github.com/Trevelopment/MZD-AIO), Commit `409c724ed860497b2a34f9367cb4a019287846ea`. Die ausgewählten Referenzdateien samt Quellbaum liegen im benachbarten Ordner `aio_reference/`; sie wurden nur gespeichert, nicht ausgeführt.

- `aio_target_inventory.tsv` ordnet wörtliche Zielpfade aus den AIO-Tweakskripten den bereits abgeschlossenen Gerätearchiven zu. Die Liste enthält auch Verzeichnisse, optionale Erweiterungen, Platzhalter und `.org`-Backups; ein fehlender Eintrag bedeutet daher nicht automatisch einen Lesefehler.
- `aio_v70_comparison/comparison.tsv` und die zugehörigen `.diff`-Dateien vergleichen 24 verfügbare Textdateien mit den in AIO mitgelieferten v70-Originalen. 15 unterscheiden sich. Gleichnamige Dateien aus anderen Komponenten wurden nicht zugeordnet. Das ist eine Vergleichsgrundlage, noch keine Aussage über die Funktionsfähigkeit eines einzelnen Patches unter v74.
- Bereits gesichert sind u. a. `Common.js`, `systemApp.js`, Diagnose-GUI, Bedienelemente, CSS, `sm.conf`, Opera-Konfiguration, Startskripte und Terminalprogramm.
- `analysis_files/` enthält ausgewählte reguläre Textdateien zum direkten Durchsuchen. Für Originalmetadaten, Binärdateien und vollständigen Umfang sind die Archive maßgeblich.

## Grenzen

Dies ist eine Dateisicherung eines laufenden Systems mit ergänzenden kleinen Boot-Abbildern, kein vollständiges, atomisches Flash-Image. Schreibbare Datenbanken und Logs können sich während des Lesens ändern. Die großen Root-/Daten-/Ressourcen-Blockgeräte werden nicht roh dupliziert. Persönliche Einstellungen und eventuell Kontakte, Nachrichten, WLAN-Konfiguration oder Schlüssel können in den Datenarchiven enthalten sein.

Andere Chats wurden nicht eingesehen. Grundlage sind diese Sitzung, die lokal bereitgestellten Dateien, das ausgelesene Gerät und die genannte öffentliche AIO-Referenz.

Status lokal abrufen: `python backup_status.py` im Projektordner.
