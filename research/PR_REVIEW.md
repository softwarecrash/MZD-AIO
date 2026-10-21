# Offene Pull Requests – Bewertung

Stand 21.10.2026: **28 offene PRs**, davon 4 manuell erstellte und 24 Dependabot-Updates. Für jeden wurden PR-Details, alle gemeldeten geänderten Dateien, Gesprächskommentare, Reviews und Inline-Kommentare erfasst. Bei allen offenen PRs waren beim Abruf jeweils 0 Gesprächskommentare, 0 Reviews und 0 Inline-Kommentare vorhanden. PR-Beschreibungen mit Testangaben sind Aussagen der jeweiligen Autoren; hier wurde kein Desktop-Build oder Fahrzeugtest ausgeführt.

## Manuelle Änderungen

| PR | Umfang und Bewertung | Weiterverwendung |
|---|---|---|
| [#230](https://github.com/Trevelopment/MZD-AIO/pull/230) | 3 Dateien; 24 hinzugefügte, 12 entfernte Zeilen. Updater-URL prüfen, Translate-Fehler abfangen, konkreter Wi-Fi-AP-Pfad und Copy-Callback-Reihenfolge. Fehlerbilder passen zu #94/#199/#212/#217. Autor meldet macOS-x64-Build, Signatur/DMG und temporären Dateisystemtest; kein Fahrzeugtest.|**Zuerst isoliert prüfen.** Der Desktop-Fix ist kein v74-Funktionsnachweis. Wiederholtes Kompilieren, AP/ADB-Kombinationen und Abbruchpfade testen. |
| [#231](https://github.com/Trevelopment/MZD-AIO/pull/231) | 10 Dateien; 1049 hinzugefügte, 221 entfernte Zeilen. UI-Umbau mit neuer Navigation, Auswahlzuständen und CASDK-Layout. Enthält die Änderungen aus #230; zusätzlicher UI-/Vendor-Code. Autor meldet macOS-Prüfung, keinen Fahrzeugtest.|**Ideenquelle für Bedienung, nach Basisfixes.** Nicht zusätzlich zu #230 blind cherry-picken; gleiche Änderungen und andere gemeinsame Basishistorie berücksichtigen. |
| [#207](https://github.com/Trevelopment/MZD-AIO/pull/207) | 6 Dateien; 127 hinzugefügte, 45 entfernte Zeilen. Linux-Containerrezept, RPM-Ziel, neue Skripte; bleibt auf Node 13. Im vorgeschlagenen Dockerfile steht LABEL vor FROM und das Rezept nutzt archivierte Debian-Quellen.|**Als Buildansatz übernehmen, nicht unverändert.** Dockerfile-Reihenfolge und Paketinstallation tatsächlich testen; kein Firmwarepatch. |
| [#219](https://github.com/Trevelopment/MZD-AIO/pull/219) | 1 Datei, 21 Zeilen. SECURITY.md-Vorlage, ohne Laufzeitcode und ohne Firmwareänderung.|**Niedrige technische Priorität.** Verantwortliche, Kontakt und unterstützte Versionen müssten für den Fork konkret gepflegt werden. |

## Alle offenen PRs mit festgehaltenem Quellstand

Die JSON-Dateien enthalten GitHubs Patchfragmente. Diese sind Recherchematerial, keine garantierten vollständigen, direkt anwendbaren .patch-Dateien. Große Dateien können ohne Patchfeld zurückkommen; Details unten. Ein Head-SHA hält den analysierten Stand fest, auch wenn der PR später geändert wird.

| PR | Autor | Geänderte Dateien | Head-SHA | Einordnung |
|---|---|---|---|---|
| [#231: Redesign macOS tweak workflow](pull-requests/231.json) | herasymchyk-oleksii | `DESIGN.md`, `PRODUCT.md`, `app/assets/css/modern.css`, `app/assets/js/build-tweaks.js`, `app/assets/vendor/w3.js`, `app/controllers/home.js`, `app/index.html`, `app/main.js`, `app/views/casdk.htm`, `app/views/main.htm` | `9a60352a467726bfc0ca369ab26a06dccfc14705` | Siehe Einzelbewertung oben |
| [#230: Fix macOS startup and Wi-Fi AP configuration errors](pull-requests/230.json) | herasymchyk-oleksii | `app/assets/js/build-tweaks.js`, `app/index.html`, `app/main.js` | `1322731803c0197681c799de875309fda8bdfe23` | Siehe Einzelbewertung oben |
| [#219: Create SECURITY.md](pull-requests/219.json) | tevin1e12 | `SECURITY.md` | `ee14237b81cebf23da830585c451dee91f88252d` | Siehe Einzelbewertung oben |
| [#207: Updated GNU/Linux Build Instructions](pull-requests/207.json) | KernelGhost | `package.json`, `scripts/Dockerfile.linux`, `scripts/README.md`, `scripts/build_linux.sh`, `scripts/build_linux_deb.sh`, `scripts/build_linux_deb_helper.sh` | `a6e3816ddacbfb28065194f310ea950dd9dfda39` | Siehe Einzelbewertung oben |
| [#203: Bump app-builder-lib and electron-builder](pull-requests/203.json) | dependabot[bot] | `package-lock.json`, `package.json` | `c5b60b9632faf08c9009f74ac280ded9b44d6885` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#195: Bump electron from 6.1.12 to 22.3.25](pull-requests/195.json) | dependabot[bot] | `package-lock.json`, `package.json` | `b11eaf1ea44a1a4d970e8ca8d0b31945f29f624d` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#194: Bump semver from 5.7.1 to 5.7.2 in /app](pull-requests/194.json) | dependabot[bot] | `app/package-lock.json` | `b7c300caa74a44fcfd8193063ba60119a97f1228` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#168: Bump ejs, electron-builder and spectron](pull-requests/168.json) | dependabot[bot] | `package-lock.json`, `package.json` | `ccfed4817c5c6fb473d739af63402216eb7f5b89` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#167: Bump json5 from 2.1.1 to 2.2.3](pull-requests/167.json) | dependabot[bot] | `package-lock.json` | `9783e230efa7b220ff91f5c9f5546bb099257125` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#166: Bump simple-get from 3.1.0 to 3.1.1 in /app](pull-requests/166.json) | dependabot[bot] | `app/package-lock.json` | `abf21682d4f5c50434eeca7d66e111428bf744bb` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#165: Bump flat and mocha](pull-requests/165.json) | dependabot[bot] | `package-lock.json`, `package.json` | `25a921d2fbe313f9df02f467fa0fa3bb2ac9a16f` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#162: Bump qs from 6.5.2 to 6.5.3](pull-requests/162.json) | dependabot[bot] | `package-lock.json` | `8bbd81fab7f0aa09c7727dd3901a44852a46d7ae` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#159: Bump decode-uri-component from 0.2.0 to 0.2.2](pull-requests/159.json) | dependabot[bot] | `package-lock.json` | `1b16499cde6cdb3f899aec855b704a1b29eb7f8c` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#153: Bump thenify from 3.3.0 to 3.3.1](pull-requests/153.json) | dependabot[bot] | `package-lock.json` | `19a18149c2166dcd93ff8e0d368d1fc88e6f8dbc` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#152: Bump thenify from 3.3.0 to 3.3.1 in /app](pull-requests/152.json) | dependabot[bot] | `app/package-lock.json` | `92c149629e1e96ab40bfe35a6e666c7b06a349ba` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#148: Bump async from 3.1.0 to 3.2.2](pull-requests/148.json) | dependabot[bot] | `package-lock.json`, `package.json` | `329d0e331f566bdeb4a64372fc2648a3886da8e6` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#144: Bump ajv from 6.10.2 to 6.12.6 in /app](pull-requests/144.json) | dependabot[bot] | `app/package-lock.json` | `9a1b17fd8df4b0ffcc1eaf255d30d6593a3b17de` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#143: Bump ajv from 6.10.2 to 6.12.6](pull-requests/143.json) | dependabot[bot] | `package-lock.json` | `a04b97aed52351e90731f39370d9e9797c4e657f` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#142: Bump pathval from 1.1.0 to 1.1.1](pull-requests/142.json) | dependabot[bot] | `package-lock.json` | `9d24f458d2f50baa3bbb8e8e12be7dfd772dafa4` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#140: Bump shelljs from 0.8.3 to 0.8.5](pull-requests/140.json) | dependabot[bot] | `package-lock.json`, `package.json` | `2565f3552c3798b350463ed75e1f16b3efd5f068` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#134: Bump tar from 4.4.13 to 4.4.19](pull-requests/134.json) | dependabot[bot] | `package-lock.json` | `a88b12ec1429fea20ad8445bf26f1807164cf23d` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#131: Bump path-parse from 1.0.6 to 1.0.7](pull-requests/131.json) | dependabot[bot] | `package-lock.json` | `4614c04be8400a5c09ce6cd299fcd960963cb202` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#121: Bump normalize-url from 4.5.0 to 4.5.1](pull-requests/121.json) | dependabot[bot] | `package-lock.json` | `280f50df84510b92f106f903aea5abce269f7fdc` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#120: Bump glob-parent from 5.1.0 to 5.1.2](pull-requests/120.json) | dependabot[bot] | `package-lock.json` | `4b312e60b4f052eb09ffe19d720c19ea6fb327c6` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#117: Bump hosted-git-info from 2.8.5 to 2.8.9](pull-requests/117.json) | dependabot[bot] | `package-lock.json` | `81d9a8e571a8ed3706bdc6db57a172d9944c09fa` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#114: Bump lodash from 4.17.15 to 4.17.21](pull-requests/114.json) | dependabot[bot] | `package-lock.json` | `5c39387fb57e6a832601f5cbd79c87638e7bdcd0` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#113: Bump lodash from 4.17.15 to 4.17.21 in /app](pull-requests/113.json) | dependabot[bot] | `app/package-lock.json`, `app/package.json` | `f9e601d48943f045286f30b29061fe3b1d922f2a` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |
| [#112: Bump handlebars from 4.5.3 to 4.7.7](pull-requests/112.json) | dependabot[bot] | `package-lock.json` | `4856ea645bc56379a3e7d02ba06bd1de67cf375e` | Historisches Dependency-Update; gezielt ersetzen, nicht ungeprüft mergen |

## Dependency-Updates

Die 24 Bot-PRs ändern überwiegend Manifeste und Lockfiles, keine CMU-Tweaks. Betroffen sind Electron, electron-builder/app-builder-lib, semver, ejs/spectron, json5, simple-get, flat/mocha, qs, decode-uri-component, thenify, async, ajv, pathval, shelljs, tar, path-parse, normalize-url, glob-parent, hosted-git-info, lodash und handlebars. Mehrere Updates betreffen Root- und app-Abhängigkeitsbäume separat.

Eine moderne Toolchain muss zusammenhängend für Electron, Node, native Module, Packaging und Tests geprüft werden. Ein alter offener Bot-PR allein ist kein heutiger Aktualitäts-/Sicherheitsnachweis. Die damaligen Versionsziele sind keine Empfehlungen für einen neuen Release.

## Historische PRs

22 geschlossene PRs wurden mit Status und gegebenenfalls Mergezeitpunkt erfasst: [closed-index.json](pull-requests/closed-index.json). Darunter #5 (Node-Unterstützung), #23 (README), #110 (y18n) mit Mergezeitpunkt; andere geschlossene PRs ohne Mergezeitpunkt nicht als übernommen behandeln. #169 fehlte in der Issues-Auflistung und wurde durch Abgleich mit der PR-Liste einzeln nacherfasst.

## Grenzen der Patchfragmente

- PR #203: `package-lock.json` (modified, Blob `417474fa158339c332205775e80d560ec46e9c2d`) ohne Patchfeld; am gepinnten Head separat abrufen.
- PR #168: `package-lock.json` (modified, Blob `4d72810a032410a263a9534021c2532bc65dda18`) ohne Patchfeld; am gepinnten Head separat abrufen.

### Ergänzung: fehlende Lockfile-Patches nacherfasst

Die vollständigen Head-Dateien sind jetzt zusätzlich archiviert: [#203 package-lock.json](pull-requests/material/203/package-lock.json), [#168 package-lock.json](pull-requests/material/168/package-lock.json). Quelle sind jeweils die oben festgehaltenen Head-SHAs. Diese Dateien wurden nicht installiert. Die Dateiinhalte ermöglichen weitere Vergleiche; die API-Patchfragmente werden dadurch nicht nachträglich vollständig.
