# Fork-Recherche für den AIO-Neuaufbau

Stand: **21.10.2026**. Vergleichsbasis: Trevelopment/MZD-AIO `409c724ed860497b2a34f9367cb4a019287846ea`.

**Es gibt relevante aktive Weiterentwicklungen, darunter einen ausdrücklich benannten v74-Branch. Ein vollständig abgesicherter Port für 74.00.311 EU N oder 74.00.324 EU N ist damit nicht belegt.** Desktop-Reparaturen, Zugang zur CMU und funktionierende Fahrzeug-Tweaks bleiben getrennte Aufgaben.

## Die wichtigsten Funde

| Quelle | Nutzen für unser Vorhaben | Nachweis und Grenze |
|---|---|---|
| [Austin-Metke: v74-support](https://github.com/Austin-Metke/MZD-AIO/tree/3d2a1c984a4409e9d69de90c7b49997fa63253d1) | Ausgewählte v74-Tweaks, Sperren für ungetestete Funktionen; Desktop mit Electron 44 / IPC und Paketbau-Tests | Autor nennt Nutzerberichte zu 74.00.324. Originalberichte werden im Commit nicht verlinkt. Weiterhin komplette v70-Dateien; kein eigener CMU-Nachweis |
| [Otamay: master](https://github.com/Otamay/MZD-AIO/tree/f18ac13919a89e3ce869ac937751813f1d982e88) | v74-Versionsprüfung und WLAN-Muster mit Wireless CarPlay | Drei kleine Änderungen statisch nachvollzogen; kein nachgewiesener kompletter Port |
| [baktrak09: AA-Forschung](https://github.com/baktrak09/MZD-AIO) | Audio-Fokus, ALSA/PCM-Diagnose, experimenteller Touch für Werks-AA; Paketbau-/Installer-Tests | Audio-PR sagt ausdrücklich nicht kompiliert / nicht im Auto getestet; Touch nur 70.00.335C und experimentell |
| [n3k0lai: rust-nix](https://github.com/n3k0lai/MZD-AIO/tree/4a9f9fdf440b02ae3d43bb5db587e71a50e3fb2d) | Firmwareprofile als Daten, Plan/Prüfung vor Änderungen, CLI statt Electron | Neuaufbau, laut README noch ohne Fahrzeugtest. Zielprofile 59.00.540 und 70.00.352B, kein v74-Profil |
| [herasymchyk-oleksii](https://github.com/herasymchyk-oleksii/MZD-AIO) | macOS-Start, WiFi-AP, neue Oberfläche | Bereits als Upstream-PRs 230/231 erfasst; 231 enthält 230 |
| [j00bi](https://github.com/j00bi/MZD-AIO/tree/fe3c42cf4cd333cdd8ce46b812bcf6bf898ebe57) / [grepmykeys](https://github.com/grepmykeys/MZD-AIO/tree/300c21ce36f18ebb5867bd44e5aa72332a414a0e) | Weitere Desktop-Reparaturen, moderne Electron-/Node-APIs | Unterschiedliche Lösungen und offene Probleme; grünes CI allein bestätigt keinen erfolgreichen Build oder Fahrzeugbetrieb |

## Einstieg und Material

- [Detaillierte Bewertung und Übernahmereihenfolge](FINDINGS.md)
- [Alle 121 Fork-Einträge](FORK_INDEX.md)
- [89 verschiedene Heads über 646 Branchreferenzen](BRANCH_INDEX.md)
- [Erfassungsumfang, Grenzen und Wiederholung](COVERAGE.md)
- [Metadaten und alle Branch-SHAs](inventory.json)
- [Vergleichsdaten, zusätzliche Commits und Dateilisten](heads.json)
- [Alle erfassten Fork-Issues/PRs und Gesprächskommentare](discussions.json)
- [Vertiefte Reviews zu vier ausgewählten PRs](reviews.json)
- [CI und Release-Abfragen der zehn Schwerpunkt-Forks](checks-and-releases.json)

`patches/` enthält ausgewählte textuelle GitHub-Patchfragmente mit festem Head, Basis und Quell-URL. Bei baktrak09 sind Audioänderungen zusätzlich gegen den importierten Headunit-Grundstand isoliert. `tree-deltas/` ergänzt die auf 300 Dateien begrenzten Compare-Antworten für Rust-Neuaufbau und ImgBot. `sources/` bewahrt ausgewählte Dokumentation, Installer und CI-Definitionen am geprüften SHA.

## Konsequenz für unseren Fork

Zuerst die Desktop- und Paketbau-Reparaturen gegeneinander prüfen; anschließend **74.00.311 EU N und 74.00.324 EU N als getrennte Profile** mit Originaldatei-Hashes behandeln. Austins v74-Änderungen sind der unmittelbarste Ausgangspunkt, sollten aber nicht ungeprüft übernommen werden. Besonders die Ersetzung kompletter v70-`systemApp.js`-/List2-Dateien muss anhand echter v74-Dateien ersetzt oder nachgewiesen werden.

Es wurden ausschließlich Recherchedateien ergänzt. Keine fremden Programme, Installer oder Binärdateien ausgeführt, kein Tweak installiert und keine Laufzeitkorrektur übernommen.
