# Erfassungsumfang und Grenzen

Stand: 21.10.2026.

## Vollständigkeit des GitHub-Korpus

| Inhalt | Erfasst |
|---|---:|
| Issues (ohne Pull Requests) | **181** |
| Davon offen / geschlossen | **76 / 105** |
| PR-Diskussionen insgesamt | **50** |
| Davon offen / geschlossen | **28 / 22** |
| Gesprächskommentare zu Issues und PRs | **655** |
| Erwartete Kommentare aus den Zählern der Vorgänge | **655** |
| Reviews / Inline-Kommentare der offenen PRs | **0 / 0** |
| Textbausteine direkt unter app/files/tweaks inventarisiert | **124** |

Issues wurden mit state=all und per_page=100 in drei Seiten erfasst. Kommentare wurden über die repositoryweite Issue-Comment-Collection in sieben Seiten erfasst und den Vorgängen zugeordnet. Die PR-Listen offen/geschlossen wurden zusätzlich abgeglichen. **PR #169 fehlte in der allgemeinen Issues-Auflistung und wurde separat nacherfasst**, daher 231 vollständige Vorgänge statt zunächst 230. Alle Nummern 1 bis 231 sind nach diesem Abgleich vertreten.

Für alle 28 offenen PRs wurden Detaildatensatz, Dateiliste, Reviews und Inline-Kommentare geholt. Die jeweilige Länge der Dateiliste stimmt mit changed_files überein; alle Listen lagen unter einer 100er-Seite. Historische geschlossene PRs haben hier Metadaten und Gesprächskommentare, aber kein vollständiges Diff-/Reviewarchiv.

## Patchumfang

GitHubs Dateiliste liefert Patchfragmente. Bei PR #203 und #168 fehlt das Patchfeld für package-lock.json; die vollständigen Lockfile-Inhalte wurden deshalb separat vom festgehaltenen Head unter pull-requests/material/203/ und /168/ gesichert. Das API-Patchfragment bleibt weiterhin unvollständig. Auch vorhandene große Patchfelder sind nicht als garantierte vollständige, anwendbare Diffs zu behandeln. Die manuell erstellten PRs #230/#231/#207/#219 wurden anhand ihrer Beschreibungen und Codeänderungen eingeordnet; Dependency-PRs anhand der geänderten Dateien/Patchfragmente als historische Toolchainänderungen erfasst.

## Interpretation und Grenzen

- Komplette Textdiskussionen liegen im Snapshot und pro Vorgang als Markdown vor; Hauptbefunde sind im Ergebnisdokument gebündelt.
- Verlinkte Screenshots, Videos, Binäranhänge und fremde Cloud-Backups sind **nicht** vollständig heruntergeladen/inhaltlich untersucht. Bild-only-Fehlerberichte ohne Text bleiben entsprechend unklar.
- Externe Threads/Repositories sind zunächst Quellen und Ansatzpunkte. Das ist kein vollständiger Crawl aller Mazda-Foren oder aller Forks.
- Die Issues sind öffentliches Nutzermaterial; Antworten können veraltet, spekulativ, widersprüchlich oder sachlich falsch sein. Nicht jede positive Meldung benennt genaue Firmware/Hardware.
- Kein eigener Desktop-Build, kein Einspielen fremder PRs, kein Fahrzeug-/Prüfstandtest, kein Firmwareflash. Statische Prüfungen betreffen die ausdrücklich genannten Quelldateien.
- Kein unbekannter Download wurde ausgeführt. Keine Nutzerdaten/Firmwaredumps aus einer CMU liegen vor.
- Inhaltlich redigiert wurden eingebettete E-Mail-Adressen und GitHub-Abmeldetoken aus E-Mail-Zitaten. Benutzername, Datum und Originalquelle bleiben erhalten. Die Markdown-Darstellung normalisiert Zeilenenden und abschließende Leerzeichen; der JSON-Snapshot bewahrt die übrigen Diskussionstexte.
- Quellstand und Abrufdaten sind festgehalten. Ein Live-Issue kann sich nach dem Abruf ändern.
- Lizenzmetadaten sind keine Prüfung jeder mitgelieferten OEM-/Drittanbieterdatei. Vor einer Neuveröffentlichung von Ressourcen deren Herkunft gesondert klären.

## Lokale Qualitätsprüfung

Vor dem Commit prüfen: 231 eindeutige Vorgänge, 181 echte Issues, 655 eindeutig zugeordnete Kommentare, 28 offene PR-Dateilisten, lokale Markdown-Verweise, gültige JSON-Dateien, Quellen/Hashes, git diff --check. Diese Kontrollen prüfen die Rechercheablage, nicht die Funktion von AIO auf v74.
