# MZD-AIO Rework – Recherche

Aktueller v74-Umfang: [REWORK-SCOPE.md](REWORK-SCOPE.md). Die dort ausgeschiedenen Alt-Tweaks sind keine offenen Aufgaben.

Stand: 21.10.2026. Ziel: AIO auf einen ausdrücklich benannten aktuellen Gen-6-Firmwarestand portieren und die Anwendung vereinfachen. Laut Nutzerfund in einer E-Mail ist **74.00.311 EU N** der vermutete Iststand (noch nicht am Gerät abgelesen). **74.00.324 EU N** ist der spätere, öffentlich belegte reguläre EU-Zielstand; beide Profile werden getrennt behandelt. Andere Regionen, CMU-Revisionen und insbesondere 74.00.331 werden getrennt behandelt. „v74“ ist keine allgemeine Kompatibilitätszusage.

## Einstieg

- [Ergebnisse und belastbare Ansatzpunkte](FINDINGS.md)
- [Firmware- und Funktionsmatrix](FIRMWARE_MATRIX.md)
- [Offene PRs mit Bewertung](PR_REVIEW.md)
- [Alle Forks: v74-Ansätze, Desktop-Reparaturen und AA-Experimente](forks/README.md)
- [Alle Issues und historischen PR-Diskussionen](ISSUE_INDEX.md)
- [Quellcode-Landkarte](CODE_MAP.md)
- [Quellen, Downloads und verknüpfte Projekte](SOURCES.md)
- [Arbeitsreihenfolge und Prüfkriterien](ROADMAP.md)
- [Erfassungsumfang und Grenzen](COVERAGE.md)

## Was AIO tatsächlich baut

1. Das Electron-/AngularJS-Projekt erzeugt die **Desktop-Anwendung** für Windows, macOS oder Linux.
2. „Start Compilation“ in dieser Anwendung stellt **ausgewählte Skriptbausteine und Dateien** zu einem USB-Installationspaket zusammen.
3. Der Installer verändert Dateien im laufenden Mazda-Linux, installiert Zusatzprogramme oder ersetzt Oberflächendateien.

Dabei wird **kein vollständiges Mazda-Firmwareimage aus Quellcode kompiliert**. Einige Komponenten wie Android-Auto-Headunit sind eigenständige Binärprogramme aus anderen Projekten. Zugang zur Shell, erfolgreiche Installation und funktionierender Tweak sind drei getrennte Nachweise.

## Evidenz lesen

- **Im Quellcode nachvollzogen:** statische Prüfung am erfassten Stand; kein Laufzeittest.
- **Von Nutzern bestätigt:** konkreter Rückbericht mit Versions-/Gerätebezug; keine eigene Reproduktion.
- **Vorschlag:** mögliche Änderung ohne abschließenden Erfolgsnachweis.
- **Fehlerbericht/offen:** Problem belegt, Ursache oder Lösung nicht nachgewiesen.
- **Historisch:** brauchbare Spur, aber kein Nachweis für 74.00.324 EU.

Ein geschlossenes Issue gilt nicht automatisch als gelöst. Ein offener PR gilt nicht als getestet oder übernahmefähig. In dieser Recherche wurde kein Tweak auf einer CMU ausgeführt und kein PR in den Programmcode übernommen.

## Ablage

`upstream-snapshot.json` enthält die erfassten Diskussionstexte mit Quellen, Zeitstempeln und Autoren. `threads/` macht diese Texte pro Vorgang lesbar. `pull-requests/` enthält für alle offenen PRs Detaildaten, Dateilisten und die von GitHub gelieferten Patchfragmente. `evidence/` hält eigene statische Messungen fest. Anhänge und andere Repositories sind zunächst mit Fundstelle inventarisiert; Firmwaredateien und ungeprüfte Downloads werden nicht als fertige Pakete angeboten.
