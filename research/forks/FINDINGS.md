# Bewertung der aktiven Forks

Stand: 21.10.2026. Bewertungen sind statische Recherche, soweit nicht ausdrücklich als Aussage eines Autors bezeichnet.

## 1. Austin-Metke: konkreter v74-Ansatz, aber noch kein belastbarer Port

Heads: Desktop `67788a600cb4b33b4e9a6adb1c562770bc53c2d3`; `v74-support` `3d2a1c984a4409e9d69de90c7b49997fa63253d1`. Der v74-Branch enthält den Desktopstand plus zwei Commits.

[Commit 6b24afd](https://github.com/Austin-Metke/MZD-AIO/commit/6b24afd9d1d56f6b3c8ca2a1a5d58913730d4afd) sagt, Besitzer hätten auf 74.00.324 v70-Codepfade verwendet und funktionierende Tweaks gemeldet. Das ist ein konkreter Hinweis, aber ohne dort verlinkte Einzelberichte, Region, CMU-Revision oder Vorher-/Nachherdateien. Die Formulierung „community-tested“ ist die Aussage des Autors, kein eigener Prüfnachweis.

Im Code:
- Neue Kompatibilitätsgruppe 8 akzeptiert `_VER -ge 74`, also auch unbekannte spätere Hauptversionen.
- Menü-/Listenloop, Disclaimer, Audio-Reihenfolge und Datum erhalten v74-Pfade.
- Der Paketbauer umschließt unter anderem WLAN, SSH-Bringback, Castscreen, AIO-App, MZD Meter, Legacy-AA und CASDK mit einer Installationssperre für Gruppe 8. Die konkrete Schreibweise im Code lautet SSH_BRINGBACK.
- `00_59patch.txt` kopiert für Gruppe 8 weiterhin die komplette `systemApp.70.js`. Disclaimer/Audio-Reihenfolge verwenden ebenfalls v70-Ressourcen; Listenloop kopiert eine alte komplette `List2Ctrl.js`.
- Das Weglassen von `v70_integrity_check` verhindert somit **nicht alle** v70-Dateiersetzungen. Der mögliche Verlust neuer v74-/Wireless-CarPlay-Funktionen bleibt zu prüfen.
- Die Sperre um Skriptausführung ist kein vollständiger Nachweis, dass alle zuvor ausgewählten Ressourcen bereits beim Paketbau entfallen.

Der Playwright-Integrationstest startet die echte Desktop-App und prüft erzeugte Pakete, Sperr-Wrapper und einmalige Ausgabe bei fehlender Albumgrafik. Er führt keinen v74-Installer auf einer CMU aus. Der Fix für doppelte Ausgabe behandelt einen Fehler-/Close-Event-Pfad moderner Node-Streams und ist als eigener Desktop-Kandidat interessant.

Der Desktopzweig modernisiert Electron auf 44, ersetzt remote-Zugriffe durch IPC, überarbeitet Dateihilfen und ZIP-Behandlung und repariert Linux-Icons. Das ist ein umfangreicher alternativer Ausgangspunkt, kein kleiner direkt zu mischender Patch. In der Release-/Actions-Abfrage wurden keine Releases oder Runs gefunden.

Material: [Desktop-Patches](patches/Austin-Metke--main.json), [v74-Patches und Commitbasis](patches/Austin-Metke--v74-support.json), vollständige Committexte in [heads.json](heads.json).

## 2. Otamay: kleine, gut isolierbare v74-Änderungen

Head `f18ac13919a89e3ce869ac937751813f1d982e88`, drei zusätzliche Commits / drei Dateien.

Die Versionsprüfung nimmt 74 zusätzlich in den 70er-Zweig auf. Dadurch wird die vorhandene Gruppeneinteilung weiterverwendet; keine neue genaue Firmwareidentifikation. Die WLAN-Änderung sucht ein v74-Muster mit `_supportedWirelessCarPlay` und ersetzt die passende Bedingung. Das kann einen Unterschied zum bisherigen WLAN-Patch erklären, braucht aber exakte Originaldateien beider EU-Zielversionen. Ein weiterer Commit korrigiert einen Tippfehler in FuelConsumptionCtrl.

Keine eigenen Diskussionen, Releases oder Actions-Runs gefunden. **Ansatz für Versions-/WLAN-Analyse, kein Beleg für AIO-Gesamtkompatibilität.**

Material: [Patchfragmente](patches/Otamay--master.json).

## 3. baktrak09: Audioexperimente und Touch für Werks-Android-Auto

Sieben Branches. Der erste Commit `a6ed0e5e915c25ed6a0b3d443b05f548f9baaeb1` importiert einen Headunit-Grundstand. Der Großteil der zunächst sichtbaren neuen Dateien ist dieser Import. Deshalb sind die tatsächlichen Änderungen zusätzlich gegen diesen Stand verglichen.

| Branch | Head | Inhalt |
|---|---|---|
| aa-audio-diagnostics | 8795738e5df78a79585f9cfdfcf0d7f6ed53c559 | PCM-/Audio-Diagnose |
| aa-factory-audio-routing-test | 2fedd8134229dfdb7f87c78905882e81fed985b7 | Routing über Werks-Audiopfade |
| aa-focus-state-fix-20261008 | 1d4bcf45ae32685658b34c9892d14ec86bf3d73e | Fokusübergabe / Sessiontracking |
| aa-native-focus-stream-test | 1838d2c7ec3f2ae489bb116464f7ef10033a9a92 | Native Fokus-/Streamversuche |
| aa-factory-integration-repair | a0cbb953f6a550324de345406f37a60bd996c66e | Sessionprüfungen, ALSA-Fehlerpfade, Wiederherstellung der Oberfläche |
| factory-aa-touch-fw70 | c6a9b361e2fe80b2eb1309b1db3f236aa14a4153 | OEM-AA-Touch, Installer und Tests; enthält auch Audioarbeit |
| aio-modernization | a6ed0e5e915c25ed6a0b3d443b05f548f9baaeb1 | Importierter Headunit-Grundstand |

[PR #1](https://github.com/baktrak09/MZD-AIO/pull/1) beschreibt ausdrücklich einen noch nicht kompilierten oder im Auto getesteten Versuch. Der Autor beansprucht **keine Lösung für stummen Ton**. Kein weiterer PR-Kommentar oder Review vorhanden. Die verschiedenen Branches dürfen nicht als sieben unabhängige fertige Fixes gezählt werden.

### OEM-Touch: nützliches Verfahren, falsche Firmware für unser Ziel

Die Dokumentation nennt **70.00.335C**, experimentell und nicht zur Fahrzeuginstallation bereit. Der Installer prüft genau diese Versionszeichenfolge und injiziert eine Bibliothek über `LD_PRELOAD` in `jciAAPA` in `/jci/sm/sm.conf`. Er prüft vorhandene Preloads, sichert die Konfiguration, verifiziert temporäre Dateien und ersetzt die Konfiguration erst anschließend. Der Uninstaller entfernt nur den erwarteten Eintrag und vergleicht das Ergebnis mit der Originalsicherung.

Wichtige Grenze: Die Dokumentation behauptet noch, die Bibliothek sei nicht importiert; der geprüfte Head enthält bereits `libmazda_touch.so` und `factory-aa-touch-src/`. Dokumentation und Code sind hier nicht synchron. Der im Installer erwartete Bibliotheks-SHA256 lautet `46f96c6a38fa54db5b0ace81895feadcb672ae5708a7561f7a5eb2ce8b6be777`. Das ist der hinterlegte Sollwert; wir haben die Binärdatei nicht heruntergeladen und selbst gehasht. Ohne `sha256sum` sieht der Installer nur einen schwächeren Nachkopiervergleich vor.

Der erfolgreiche Workflow am erfassten Head prüft Python-Installerfälle, JavaScript-/Shellsyntax, den Paketbauer und ein USB-Vorschaupaket unter Ubuntu. Er kompiliert und validiert den Hook nicht gegen eine echte CMU und belegt keine ABI-/Offset-Kompatibilität mit v74.

Material: [Touch-Patches und Quellen](patches/baktrak09--factory-aa-touch-fw70.json), Audio-Deltas in den benachbarten `--audio.json`-Dateien, festgehaltene Installer/Dokumentation unter `sources/`.

## 4. n3k0lai: eigenständiger Rust-/Nix-Neuaufbau

Head `4a9f9fdf440b02ae3d43bb5db587e71a50e3fb2d` auf `rust-nix`; Default-Branch unverändert. Zehn zusätzliche Commits ersetzen die alte Desktop-Anwendung durch einen CLI-/MCP-Ansatz mit Firmware-, Katalog-, Planungs- und Sicherheitsmodulen.

Besonders interessant: Firmwarekompatibilität als TOML-Daten; Ziel-/ungetestet-/historisch-/gesperrt-Status; unbekannte Profile gesperrt; Plan/Prüfung vor Änderungen; Strategien für Sicherungen und Mindestfreiplatz. Diese Struktur passt zu getrennten Firmwareprofilen besser als weitere lose Versionsbedingungen.

Die README sagt ausdrücklich: frühe Entwicklung, kein Test am echten Fahrzeug, synthetische CMU-Tests. Die genannten eigenen Geräte tragen 59.00.540 (Aufkleber 544) und 70.00.352B. `data/firmware.toml` enthält **kein v74-Profil**; eine nicht erfasste Version bleibt gesperrt. Aussagen über serielle Zugänge in der Profildatei sind Projektannahmen und hier kein selbst geprüfter Nachweis.

Keine Releases oder Actions-Runs gefunden. Als Architekturquelle behandeln; keine direkte Übernahme als fertigen v74-Ersatz.

Material: [Neue Textdateien als Patchfragmente](patches/n3k0lai--rust-nix.json), [vollständiger Pfadvergleich](tree-deltas/rust.json), README und Firmwareprofile unter `sources/`.

## 5. Weitere Desktop-Kandidaten

| Fork / Stand | Nutzbarer Ansatz | Einschränkung |
|---|---|---|
| herasymchyk-oleksii, PRs 230/231 | macOS-Start, funktionierende AP-Dateipfade, Oberfläche | Bereits in der ersten Recherche. 231 baut auf 230 auf; nicht doppelt übernehmen |
| j00bi, fe3c42cf4cd333cdd8ce46b812bcf6bf898ebe57 | Electron 33, Dialog-/remote-Anpassungen, WiFi-AP-Dateipfad, Entfernen des Updaters | Letzter Commit setzt webSecurity auf false für lokale Angular-Templates. Keine CMU-Skriptänderung, kein v74-Port |
| grepmykeys, 300c21ce36f18ebb5867bd44e5aa72332a414a0e | Electron 29 / Node 22, drivelist 12, mkdirp 3, remote-Migration, Build-/Release-Workflow | Reviews nennen API-/remote-/Fehlerbehandlungsprobleme. Als Befunde der Reviewer archiviert, nicht pauschal am heutigen Head bestätigt. CI installiert mit ignore-scripts; Lint darf fehlschlagen. Keine Build-/Fahrzeugbestätigung |
| axel92b, bcd2f17a7435d6d67e45551f83a17998e1205953 | Electron mit App-Verzeichnis statt Einzeldatei starten | Nur eine Änderung in package.json; der gefundene erfolgreiche Run läuft auf Upstream-SHA 409c724, nicht auf dem geänderten Head |
| hanhha, 0ac13af88b4d5b6e1a0771013bcef0935e7cf62b | Translate-Einbindung deaktivieren | Kleiner Desktop-Workaround; keine Firmwareänderung |
| javiersm, 847c44ffd7e48e2705dc0e9ed9ede426f26d3296 | performance.measure-Workaround, spanische Analysen und Windows-Bauanleitung | Globales Abfangen kann Fehler verdecken; Node-14-Anleitung ist keine moderne Toolchain. Erfolgsaussagen nicht als CMU-Nachweis belegt |
| fahhem, ebd50710d52fc4410aaa9191b600ea3b1151e6a2 | Frühere Node-/electron-builder-Anpassungen | Historischer, gegenüber Upstream zurückliegender Stand |

Bei grepmykeys zeigen eingebettete Release-Links auf `upstateautomate/MZD-AIO`; das ist keine Bestätigung eines vorhandenen Releases oder einer Kontoumbenennung. Die Releases-API des untersuchten Forks lieferte keine Releases. Die ausführlichen automatischen Reviews enthalten nützliche Prüfpunkte, aber keine Hardwaremessungen.

## 6. Restliche Forks und geringe Relevanz

Alle weiteren Forks sind im [Index](FORK_INDEX.md) eingeordnet. Die meisten enthalten nur alte Upstreamstände, bereits erfasste PR-Heads oder Dependency-Bot-Branches. Besonders viele wiederholte Branch-SHAs erzeugen den Eindruck vieler unabhängiger Weiterentwicklungen.

ImgBot in paulzay verändert zahlreiche Bildressourcen, nicht die Firmwarelogik. haribala3831 ergänzt ein Video; seksiam verschiebt einen Tweak in einen anders benannten Pfad, ohne seine Funktion zu portieren. KeanuR88 ergänzt eine Archivdatei ohne nachvollziehbaren Textpatch. Diese Binär-/Medienfunde wurden nicht ausgeführt oder als funktionierende Lösungen eingeordnet.

## Übernahmereihenfolge

1. Desktopbasis wählen: Austins neuer IPC-Ansatz gegen kleinere Reparaturen aus PR 230 / j00bi / grepmykeys abwägen. APIs, Paketbau und ZIP-/Dateipfade gezielt prüfen, statt alle Modernisierungen zu mischen.
2. Ein reproduzierbares Paketbau-/Installer-Testgerüst aus Austin/baktrak als Vorlage nutzen. Prüfungen an künstlichen Dateien klar von Prüfstandtests trennen.
3. Echte Originaldateien für 74.00.311 EU N und 74.00.324 EU N beschaffen und hashen. Austins genaue Änderungen und Otamays WLAN-Muster daran abgleichen.
4. Firmwareprofile mit exakten Versionen, Hash-Voraussetzungen, passenden Rücknahmen und Abbruch bei unbekanntem Stand einführen. Keine generelle Freigabe für alle Versionen ab 74.
5. Kleine textuelle Änderungen vor vollständigen OEM-Dateiersetzungen priorisieren. Audioexperimente und FW70-Touch als separate spätere Forschungszweige behandeln.

Diese Liste ist eine Arbeitsgrundlage. In diesem Commit wird kein Kandidat in den Produktcode übernommen.
