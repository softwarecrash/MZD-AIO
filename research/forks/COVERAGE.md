# Umfang und Grenzen der Fork-Erfassung

Stand: **21.10.2026**. Dies ist ein zeitgebundener Snapshot, keine Aussage über später angelegte Forks oder Branches.

| Prüfung | Ergebnis |
|---|---:|
| Einträge der öffentlichen Upstream-Forkliste, zwei Seiten mit je maximal 100 | 121 |
| Davon per Branchreferenzen erreichbar | 119 |
| Nicht erreichbar, Repositoryabfrage 404 | 2 |
| Erfasste Branchreferenzen | 646 |
| Verschiedene Head-SHAs | 89 |
| Neue Head-Vergleiche gegen festes Upstream-Basiscommit | 59 |
| Bereits erfasste offene Upstream-PR-Heads | 28 |
| Upstreambasis / eigener vorheriger Recherchecommit | 1 / 1 |
| Issue-/PR-Listen aller erreichbaren Forks abgefragt | 119 |
| Gefundene Vorgänge, alle Pull Requests | 21 |
| Gesprächskommentare dazu, erwartet / erfasst | 12 / 12 |
| Vertiefte PR-Reviews / Inlinekommentare in vier ausgewählten PRs | 4 / 12 |
| Schwerpunkt-Forks mit zusätzlicher Releases-/Actions-Abfrage | 10 |
| Veröffentlichte Releases in diesen zehn Abfragen | 0 |

## Vorgehen und Nachprüfbarkeit

1. Ausgangsliste: `https://api.github.com/repos/Trevelopment/MZD-AIO/forks?sort=oldest&per_page=100&page=1` und Seite 2. Alle 121 Einträge hatten in den gelieferten Metadaten `forks_count=0`; es wurden keine weiteren Unterforks darüber angekündigt. Unverbundene Kopien, private oder gelöschte Repositories sind damit nicht abgedeckt. Der Repo-Gesamtzähler meldete 119 Forks, die paginierte Liste aber 121; für diesen Snapshot zählt die konkrete Liste.
2. Für jeden Eintrag alle angebotenen Heads mit `git ls-remote --heads` erfasst. Auch Nebenbranches untersucht. Git-Tags, alte gelöschte Branches, Reflogs und nur noch in PRs enthaltene zusätzliche Fork-Heads außerhalb der bekannten Upstream-PRs sind nicht vollständig erfasst.
3. Die 89 Heads dedupliziert. 28 stimmen exakt mit den schon archivierten offenen Upstream-PR-Heads überein; Upstreambasis und eigener Recherchecommit brauchen keine neue Funktionsbewertung. Die übrigen 59 wurden gegen `409c724ed860497b2a34f9367cb4a019287846ea` verglichen. Alle zusätzlichen Commitlisten liegen unter dem abgefragten Seitenlimit von 100.
4. Vergleichsstatus, Ahead-/Behind-Zähler, Committexte und gelieferte Dateimetadaten sind in heads.json gesichert. Compare zeigt Änderungen zwischen Merge-Basis und Head; ein zurückliegender Fork bedeutet deshalb nicht zusätzliche Änderungen. Die vollständigen 646 Branch-/SHA-Zuordnungen stehen in inventory.json.
5. Bei Rust-Neuaufbau und ImgBot lieferte Compare die Grenze von 300 Dateien. Für beide wurde der vollständige rekursive Git-Tree ohne Trunkierung gegen den Upstream-Tree verglichen; tree-deltas enthält alle unterschiedlichen Pfade und Blob-SHAs. Umbenennungen dort als Entfernen/Hinzufügen. Das vervollständigt den Pfadkatalog, nicht den Inhalt jeder Binärdatei.
6. Für alle 119 erreichbaren Forks `issues?state=all&per_page=100` abgefragt. Keine Liste erreichte 100. Gesprächskommentare der betroffenen Repositories vollständig abgeglichen. Die 21 Vorgänge verteilen sich auf acidburn0zzz (16), paulzay (1), axel92b (1), baktrak09 (1), grepmykeys (2). Ein deaktivierter Issues-Tab schließt vorhandene PRs nicht aus.
7. Zusätzlich Reviews/Inlinekommentare für baktrak09 #1, axel92b #1 und grepmykeys #1/#2 abgefragt. Das ist **kein vollständiges Reviewarchiv aller Bot-/ImgBot-PRs**. Die Gesprächsdiskussionen aller 21 Vorgänge sind enthalten.
8. Actions/Release-Abfragen nur für die zehn in checks-and-releases.json genannten Schwerpunkt-Forks; dort Run-Gesamtzähler und gelieferte letzte Runs sichern. Nicht sämtliche Runlogs/Artefakte oder Veröffentlichungen aller 119 Forks untersucht.

Die zwei nicht erreichbaren Einträge sind **burtay/MZD-AIO-TI-X** und **oscarg933/MZD-AIO**. Keine Aussage über ihre heutigen Inhalte; keine Aufforderung zu Authentifizierung oder Auswertung privater Daten.

## Tiefe der Bewertung

Alle erreichbaren Forks wurden anhand von Branches, Heads, Commitlisten, geänderten Pfaden und eigenen Diskussionen gesichtet. Eigene funktionale Änderungen der relevanten Forks wurden anhand der archivierten Patchfragmente und ausgewählter festgehaltener Originaltexte vertieft. Das ist keine vollständige Zeilenprüfung aller alten, unveränderten, vendorten oder binären Inhalte.

Die Patchablage ist eine **Auswahl**, kein zum Einspielen garantiert vollständiger Diff: große Lockfiles, Binär-/Medieninhalte und der importierte Headunit-Grundstand werden nicht dupliziert. Beim Rust-Neuaufbau sind entfernte Legacy-Dateien im Pfadkatalog statt als große Löschpatches enthalten. GitHubs Patchfragmente können auch für Textdateien fehlen oder begrenzt sein. Vollständige Inhalte lassen sich über Repository und Head-SHA an der Quelle nachladen.

Die Erst-Recherche der Upstream-Issues und offenen PRs bleibt unter ../ dokumentiert. Kopierte identische Branches/PRs werden nicht als neue unabhängige Erfolgsnachweise gezählt.

## Aussagen und Tests

- Keine eigene Ausführung fremder Desktop-Apps, Installer, Shared Libraries oder Firmwarepakete. Kein Fahrzeug-/Prüfstandtest.
- Beschreibungen wie „tested“, Commitnachrichten und automatisierte Reviews sind Autorenaussagen; genauere Grenzen stehen in FINDINGS.md.
- baktrak09: erfolgreicher Host-Workflow mit synthetischen Installer-/Paketprüfungen, kein Nachweis der CMU-Bibliothekskompatibilität.
- grepmykeys: CI installiert Abhängigkeiten ohne Installationsskripte, Lint darf fehlschlagen. Ein grüner Run belegt keinen fertigen Desktopbuild.
- axel92b: gefundener Run prüft den Upstreamstand, nicht den geänderten Head.
- v74-Freischaltung und funktionierender SSH-Zugang sind kein Nachweis für jeden AIO-Tweak. Hier wurde auch kein USB-/MP3-Zugang neu nachgewiesen.
- In archivierten Diskussionen/Committexten E-Mail-Adressen und GitHub-Abmeldetoken redigiert; Benutzerkonten und Quellen erhalten. Normierte Zeilenenden/Leerzeichen dienen diff-sicherer Ablage.

## Lokale Qualitätsprüfung

Prüfen: 121 eindeutige Repositoryeinträge, 119 erreichbare, 646 Referenzen, 89 Heads, 59 neue Vergleiche, 21 PRs und 12 Gesprächskommentare, 4 Reviews und 12 Inlinekommentare; gültige JSON-Dateien, lokale Markdownlinks, eindeutige Herkunft jedes Patchbestands und git diff --check. Diese Kontrollen sichern die Rechercheablage, nicht AIO-Funktionalität.
