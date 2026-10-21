# Ergebnisse

Stand: 21.10.2026. Alle Quellen beziehen sich auf Trevelopment/MZD-AIO, soweit nicht anders angegeben. Diskussionstexte: [Index](ISSUE_INDEX.md). Die Bewertung trennt Nutzerberichte von eigener statischer Quellcodeprüfung.

## Priorität 1: Zugang und Portierung

### F01 – USB-/MP3-Zugang eröffnet einen anderen Weg als das alte ID7

**Beleg:** [#211](https://github.com/Trevelopment/MZD-AIO/issues/211), insbesondere [Verweis auf mzd-evo](https://github.com/Trevelopment/MZD-AIO/issues/211#issuecomment-2440187972); [mzd-evo/mzd-connect-1-root](https://github.com/mzd-evo/mzd-connect-1-root); [No-Touch-Fork](https://github.com/shunceyb/mzd74-tweaks-no-touch).

Der mzd-evo-JavaScriptcode öffnet Diagnose/Testfunktionen über `framework.sendEventToMmui` und Test-ID 11. Er aktiviert nicht von selbst einen dauerhaft erreichbaren SSH-Server. Der No-Touch-Fork beschreibt für v74 den weiteren Weg über Terminal, AIO und SSH_Bringback. **Bewertung:** Quellcode des Einstiegspunkts nachvollzogen; v74-Ablauf vom Projekt beschrieben; auf unserer Ziel-CMU noch nicht reproduziert. USB-Port/Mountpunkt, Diagnosebedienung und genaue Firmware sind Testvariablen. Alte Aussagen „USB ist unmöglich“ in #130/#132 sind zeitgebunden und werden durch den neueren Ansatz nicht zu aktuellen Tatsachen.

### F02 – Eine ersetzte Versionszahl macht alte Patches nicht v74-kompatibel

**Beleg:** `app/files/tweaks/00_start.txt`, `00_59patch.txt`, `09_audioorder-i.txt`, `09_audioorder-u.txt`.

`compatibility_check()` kennt 55/56, 58, 59 und 70. Für 70 prüft der Code die letzte Komponente bis 360 als Gruppe 6, darüber Gruppe 7; die Kommentare und Warntexte nennen teils abweichende Grenzen 335/336/342/352. Für 74 wird ohne Anpassung Gruppe 0 ausgegeben. Andere Bausteine ersetzen komplette `systemApp.js`-Dateien durch beigepackte ältere Varianten. **Bewertung:** statisch bestätigt. **Folgerung:** exakte Firmware-/Regionsprofile und Datei-Hashes; gezielte Änderungen statt ungeprüftem Austausch kompletter v70-Dateien. Nicht pauschal `-eq 70` durch `-eq 74` ersetzen.

### F03 – Wireless CarPlay nach AIO ausgefallen

**Belege:** [#222](https://github.com/Trevelopment/MZD-AIO/issues/222): 74.xx.331; [#229](https://github.com/Trevelopment/MZD-AIO/issues/229): 74.00.324A 4A N (ADR), CMU150, Mazda2 2022.

Das Entfernen von AIO-Einstellungen half laut #222 nicht. Beide Vorgänge haben beim Abruf keine Kommentare und keine nachgewiesene Reparatur. **Bewertung:** zwei konkrete Fehlerberichte, Ursache offen; keine eigene Reproduktion. Ein Zusammenhang mit überschriebenen v70-Oberflächendateien ist eine **Arbeitshypothese**, kein bewiesener Root Cause. WLAN, OEM-AA/CP und Regionslogik vor/nach jeder Einzeländerung vergleichen.

### F04 – SSH-Startskript enthält CRLF

**Beleg:** [#226](https://github.com/Trevelopment/MZD-AIO/issues/226); `app/files/tweaks/cmu-autorun/sdcard/recovery/02-start-sshd-and-open-firewall/start-sshd-and-open-firewall.autorun`.

Im erfassten Quellcode hat diese Datei drei CRLF-Zeilenenden einschließlich Shebang. **Bewertung:** Fehlermerkmal statisch bestätigt; Auswirkung auf unserer CMU noch zu testen. Der Desktop normalisiert in `convert2LF()` nur das generierte `tweaks.txt`, nicht automatisch alle kopierten Autorun-Dateien. Kandidat für einen gezielten Fix und eine Paketprüfung aller Shell-/Autorun-Dateien.

### F05 – SSH_Bringback ersetzt mehr als nur eine Einstellung

**Beleg:** `app/files/tweaks/00_sshbringback.txt`, `config/ssh_bringback/`.

Der Baustein kann Firewallskript, Passwort-/Schlüsseldateien und SSH-Konfiguration ersetzen; er ruft außerdem Passwort-/Konfigurationsupdate-Werkzeuge auf. **Bewertung:** statisch nachvollzogen. Für v74 zunächst den tatsächlichen Istzustand sichern und vergleichen. Eine alte Bringback-Datei blind zu kopieren ist kein minimaler SSH-Fix. Ein normaler Datei-Export ist außerdem kein vollständiger Wiederherstellungsnachweis für eine nicht mehr bootende CMU.

### F06 – Serielle Verbindung ist nicht gleich freier Login

**Belege:** [#95](https://github.com/Trevelopment/MZD-AIO/issues/95), [#135](https://github.com/Trevelopment/MZD-AIO/issues/135), [#191](https://github.com/Trevelopment/MZD-AIO/issues/191), [#201](https://github.com/Trevelopment/MZD-AIO/issues/201).

#95 enthält einen berichteten Erfolg durch Neuinstallation/Downgrade und Ausführung des Recovery-Schritts während des Updatefensters. #135 dokumentiert geänderte Passwortdateien und `neutralizeid7`; Spekulationen über Umbenennen von Autorun oder Neuverpacken einer .up-Datei haben dort keinen Erfolgsnachweis. #201 nennt Signaturprüfung als Hindernis für geänderte Updates. **Bewertung:** historischer Zugangs-/Recovery-Hintergrund; kein empfohlener v74-Downgradeplan.

## Priorität 2: Desktop-Programm wieder zuverlässig nutzbar machen

### F07 – Google-Translate-Fehler blockiert den Desktop auf mehreren Plattformen

**Belege:** [#199](https://github.com/Trevelopment/MZD-AIO/issues/199), [Bestätigung vom Maintainer](https://github.com/Trevelopment/MZD-AIO/issues/199#issuecomment-1936837222), [#217](https://github.com/Trevelopment/MZD-AIO/issues/217), [#220](https://github.com/Trevelopment/MZD-AIO/issues/220), [#212](https://github.com/Trevelopment/MZD-AIO/issues/212), [PR #230](https://github.com/Trevelopment/MZD-AIO/pull/230).

Viele Rückberichte bestätigen Start ohne Internet bzw. Blockieren von Translate. #199 enthält die konkrete externe Script-URL und Stacktrace. Die Vermutung einiger Nutzer, nur der Updater sei schuld, ist nicht die gesamte belegte Erklärung. PR #230 behandelt zusätzlich einen separaten Updater-Start ohne URL. **Nächster Schritt:** Desktop muss ohne externe Übersetzungsdienste starten und Pakete erzeugen können; Fehler beim Nachladen dürfen den Hauptablauf nicht beenden.

### F08 – Wi-Fi-AP-Kompilierung: Wildcard im Dateinamen und Kopierreihenfolge

**Belege:** [#94](https://github.com/Trevelopment/MZD-AIO/issues/94), [PR #230](https://github.com/Trevelopment/MZD-AIO/pull/230); `app/assets/js/build-tweaks.js:addWifiAP()`.

Der Altcode schreibt `*-start-wifiAP/wifiAP.config` mit `fs.writeFileSync`. Dort findet keine Shell-Globauflösung statt. Zusätzlich wird die Eingabe nicht sauber an das Ende des asynchronen Kopierens gebunden. #230 verwendet einen konkreten Ordner und setzt den Dialog hinter den Copy-Callback. **Bewertung:** Fehleransatz im Code bestätigt; PR-Autor meldet macOS-Build und temporären Dateisystemtest, ausdrücklich keinen Fahrzeugtest. Zuerst als gezielten Fix prüfen.

### F09 – Fehlende Farbschemata blockieren die Paketgenerierung

**Belege:** [#111](https://github.com/Trevelopment/MZD-AIO/issues/111), [Downloadfundstelle des Maintainers](https://github.com/Trevelopment/MZD-AIO/issues/111#issuecomment-835883854), [Erfolg mit manuellem ZIP](https://github.com/Trevelopment/MZD-AIO/issues/111#issuecomment-835894820), #156/#164/#173/#228.

Nutzer berichten sowohl Erfolg mit manuellem Entpacken als auch weiterhin nicht erkannte Dateien. Pfade sind plattformabhängig: Windows AppData/Roaming, Linux .config, macOS Library/Application Support. **Bewertung:** Workaround mehrfach beschrieben, nicht universell. Ressourcen künftig lokal auffindbar, mit klarer Fehlermeldung und optionalem Download. Keine toten externen Links im kritischen Buildpfad.

### F10 – Bintray-Downloads und alte Domains sind unzuverlässige Abhängigkeiten

**Belege:** [#126](https://github.com/Trevelopment/MZD-AIO/issues/126#issuecomment-885224391), [#111](https://github.com/Trevelopment/MZD-AIO/issues/111#issuecomment-885229331), #118/#127/#155/#171/#181/#190/#197; `package.json`.

Der Maintainer bestätigt den Verlust alter Bintray-Dateien und des Updatepfads. Neu auftauchende Inhalte auf historischen Domains sind nicht automatisch Originaldateien. **Bewertung:** bekannte Infrastrukturprobleme; alle Ressourcen mit Ursprung, Version, Lizenz und Hash inventarisieren. Die Liste in SOURCES.md speichert Fundstellen, nicht die Behauptung, jeder Link sei noch erreichbar oder vertrauenswürdig.

### F11 – Laufwerksauflistung und Ausgabepfade

**Belege:** #44/#52/#61/#68/#96/#100; [Erklärung zu drivelist](https://github.com/Trevelopment/MZD-AIO/issues/61#issuecomment-525979305).

Ein Laufwerksobjekt kann ohne verwendbaren Pfad zurückkommen; Dateierzeugung kann schon fertig sein, obwohl der Kopierdialog danach abstürzt. Pfade mit Sonderzeichen, Berechtigungen und ungemountete/virtuelle Laufwerke sind eigene Fälle. **Bewertung:** historisch analysierter Fehler mit späteren Korrekturen; Regressionstest für den neuen Desktop und frei wählbaren Ausgabeordner.

### F12 – Linux-Sonderfälle und Buildrezept

**Belege:** #64/#82/#84/#218, PR #207.

#84 nennt `carOS` vs. `CarOS` auf einem Dateisystem mit Groß-/Kleinschreibung. #218 meldet Compositor-Abstürze und einen Nutzerworkaround mit abgeschalteter Sandbox; das ist kein gewünschter Standard. #207 stellt ein containerisiertes Buildrezept vor, bleibt aber bei altem Node 13. Im vorgeschlagenen Dockerfile steht `LABEL` vor `FROM`: vor Übernahme korrigieren/mit einem echten Build prüfen. **Bewertung:** historische Hinweise plus statischer PR-Befund; Build hier nicht ausgeführt.

## Tweak-spezifische Befunde und Versuche

| ID | Thema | Beleg | Ergebnis / Einordnung |
|---|---|---|---|
| F13 | AIO-AA und OEM-AA/CP sind getrennte Implementierungen | #17/#36/#66/#80/#183/#188/#204 | Touch in AIO-AA beweist keinen Touch im OEM-AA; Bild ohne Ton und Dienstkonflikte dokumentiert. Legacy-AA nicht automatisch mit OEM-AA installieren. |
| F14 | AA ohne Ton auf v70 | #36, besonders Kommentare 447586865, 463136744, 464861740; #66 | Beenden von OEM-Diensten löste Ton nicht zuverlässig; Maintainer verwarf die reine libusb-Erklärung später selbst. GStreamer-Audio statt direktem ALSA ist eine Untersuchungsspur, kein fertiger Fix. |
| F15 | headunit fehlt / kein Speicher | #74/#78/#135 | Maintainer diagnostiziert `rm: Argument list too long` und `No space left on device`; neuer Installer wurde von Nutzern erfolgreich getestet. Zuerst freien Platz und vollständige Installation prüfen, nicht jeden Fehler als Protokollproblem behandeln. |
| F16 | AA-Schwarzbild beim Start | #63, insbesondere Kommentare 533085592, 535690276, 552234626, 559846273; #174 | Verzögerter Start, bessere Prozessprüfung und AA 1.12 werden positiv rückgemeldet; Warmstart blieb ein eigener Fall. #174 meldet Erfolg nach Abschalten von Bluetooth-Medienaudio, WLAN-AA blieb dort erfolglos. |
| F17 | Audio stottert bei Kartenanimation | #31/#49/#128/#139/#175 | SD-Karte entfernen, 2D-Karte, andere Ansicht und BT-Medienaudio abschalten helfen manchen, anderen nicht. Kein universeller Fix und kein belastbarer Beweis für „USB zu langsam“. |
| F18 | WLAN und Bluetooth beeinflussen sich | #4/#7/#19/#28/#29 | Abschalten/Deinstallieren des WLAN-AP beseitigte in #4 BT-Stottern und in #7 Bildstörungen. Hardware-/Modellbezug wichtig; AP nicht als zwangsläufig erforderlichen Standard starten. |
| F19 | GPS-/Kompassrichtung und HUD | #50/#67/#71/#87/#88/#102/#125/#136/#206/#224 | Reverse-Compass, Telefon-GPS und Kartendaten liefern unterschiedliche Ergebnisse. #88 meldet unverändert false in headunit.json. HUD-Pfeile, Einheiten und Verkehrszeichen getrennt testen. Kein fertiger CarPlay-HUD-Nachweis in #224. |
| F20 | Speedometer liefert nur Nullwerte | #45/#57/#75/#76/#215 | #45: Austausch von speedometer.js aus dem separaten Projekt wurde mehrfach bestätigt. #76: Layoutfix in 2.8.6 bestätigt. #57/#215: Datenprobleme bleiben offen; daraus keine v74-Freigabe ableiten. |
| F21 | Kein Piepsen / Listen-Freeze | #16/#24/#58 | #24: erster Fix fror die Oberfläche ein; korrigierter Anhang wurde bestätigt. #58: langer Druck auf Lenkradtaste bleibt ein anderer Pfad als GUI-Piepsen. |
| F22 | Pause on Mute | #17/#32/#35/#38 | Verhalten hängt von Firmware und geöffnetem Unterhaltungskontext ab. Laut #17 besitzt v70 das gewünschte Verhalten teilweise schon ab Werk. Kein blindes Nachrüsten. |
| F23 | Rückfahrkamera und Video/Castscreen | #30/#59/#60/#65/#72/#124 | #30 blieb ungelöst; #59 enthält Kontext-/Surface-Analyse, aber keinen bestätigten universellen Patch. #60: Vorschlag mfw_v4lsink → mfw_isink für v70, ohne abschließende Bestätigung im Thread. Rückfahransicht muss Vorrang behalten. |
| F24 | Restore und Uninstall | #7/#36/#47/#99/#141/#154/#161 | #47 meldet Bootloop nach System Restore; in #36 wurde beim AP-Entfernen der USB-Installationszugang mit entfernt. #161: nach Tweak-Deinstallation gelang offizielles Update. Rückbau pro Feature und Wiederzugang getrennt entwerfen. |
| F25 | Neue Funktionen | #2/#10/#11/#39/#54/#65/#72/#87/#119/#122/#124/#138/#147/#177/#206/#224 | Datenanzeige, Startlautstärke, Autoplay und Navigation/HUD sind Ideen. #39 verlinkt mzd-usb-sensors für externe Sensoren. Fehlende Öl-/Getriebetemperaturen sind in #2 kein bewiesener vorhandener Datenpunkt. |
| F26 | Regionen und Generationen | #6/#12/#69/#101/#105/#141/#151/#157/#208/#227 | Gleiches Modell/Baujahr genügt nicht; CN/GW-Namen und neue Mazda-Connect-Generation sind keine automatisch kompatiblen Profile. Alte Firmware <55 nicht mit diesen Dateien patchen; Kartenupdates sind ein separates Thema. |
| F27 | Speicher, Swap und Installationsreihenfolge | #3/#24/#34/#59/#74/#135 | Swap ist kein belegter allgemeiner Performancefix; alte Reihenfolgefehler verschoben Installerdateien zu früh. Freien Platz pro Partition und Abbruch/Rückbau vor Änderungen planen. |
| F28 | UI-Zustand und Bedienbarkeit | #18/#25/#27/#41/#62/#77/#133/#172/#200/#213 | Frische Auswahl statt alter Einstellungen half in #25; „Skip Confirmation“ ist bereits vorhanden (#213). Schlechte/andere USB-Sticks erklären einzelne Fälle, aber nicht jeden fehlenden Installationsstart. |

## Was davon sofort nutzbar ist

1. Rohdaten, Einzelthreads und Codefundstellen zur Fehlersuche.
2. PR #230 als eng begrenzter Desktop-Fixkandidat; #231 enthält denselben Fix plus UI-Umbau.
3. Historische getestete Fixspuren (Speedometer, Piepsen, AA-Start, Speicherbereinigung) als Regressionfälle.
4. MP3-/Diagnosezugang als Einstieg für eine **zunächst nur lesende** Bestandsaufnahme am Prüfgerät.

**Noch nicht vorhanden:** ein nachweislich vollständiges v74-AIO-Paket, ein eigener CMU-Test, ein getesteter Recoveryweg oder eine pauschale Kompatibilitätsfreigabe.

## Ergänzung: Fork-Recherche

Die [Fork-Auswertung](forks/README.md) enthält einen konkreten v74-Branch von Austin-Metke, Otamays v74-/WLAN-Anpassungen, mehrere Desktop-Neuaufbauten und baktrak09s AA-Experimente. Austins Commit nennt Nutzerberichte zu 74.00.324, übernimmt für einige Funktionen aber weiterhin vollständige v70-Dateien. Deshalb bleibt der genaue Datei-/Firmwareabgleich Voraussetzung; das ist noch kein nachgewiesener Gesamtport. Details, feste SHAs und Patchfragmente: [Bewertung](forks/FINDINGS.md).
