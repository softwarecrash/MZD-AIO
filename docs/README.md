# MZD-AIO Web-Builder / 74.00.324A EU

Statische HTML/CSS/JavaScript-Anwendung ohne Build-Schritt und ohne externe Browser-Abhaengigkeiten. Funktioniert auch beim lokalen Oeffnen von index.html. Keine Telemetrie, kein Upload.

## Bedienung wie bei AIO

- Pruefen / Preflight: 41 Funktionsgruppen durchsuchen; nur zum Testen freigegebene Patches sind auswaehlbar. Keine Systemdateiaenderung.
- Install markiert automatisch alle zum Testen freigegebenen Patches (aktuell Listenpiepsen, Listendelay, Hauptmenü im Kreis und SSH). Einzelne koennen abgewaehlt werden. Nicht bearbeitete Tweaks bleiben in allen Modi gesperrt, auch beim Projektimport.
- Installieren / Install: Listenpiepsen, Listendelay, Hauptmenü im Kreis und SSH, einzeln oder gemeinsam. Experimentell, offline geprueft, Fahrzeugtest offen.
- Deinstallieren / Uninstall: den ausgewaehlten portierten Tweak entfernen.
- Full System Restore: alle von diesem Rework unterstuetzten Systemdateien aus internen Originalen wiederherstellen, unabhaengig von der Auswahl. Derzeit List2Ctrl.js. Kein Werksreset und keine pauschale Ruecknahme fremder/alter AIO-Installationen.
- Apps To Resources: Standard fuer kuenftige neue Apps. Bestehende Systemdateien bleiben an ihrem Originalpfad. Noch keine Zusatz-App portiert.

Die 41 Gruppen fassen Install-/Uninstall-Snippets, Sprachen und Anzeigevarianten der 125 alten Skriptdateien zusammen. Drei interne Pruefbereiche sind keine Tweaks. Noch nicht portierte Tweaks sind nur im Pruef-/Planungsmodus auswaehlbar.

## USB-Start mit Tastatur

1. ZIP ins Hauptverzeichnis eines FAT32-Sticks entpacken.
2. USB-Audio: mp3/a.mp3 abspielen; alternativ b/c/d fuer andere Mountpunkte.
3. Konsole oeffnen, im OEM-Testmenue TERMINAL waehlen, auf die Shell warten.
4. `sh /mnt/sda1/tweaks.sh` eingeben. Ggf. sdb1/sdc1/sdd1 verwenden.
5. Vor Aenderungen mit j und Enter bestaetigen; sonst Abbruch. Nach Erfolg CMU selbst neu starten.

`sh /mnt/sda1/restore.sh` startet ebenfalls Full System Restore, ignoriert dabei Aktion und Auswahl im Paket. Ein neuer Stick genuegt; die Originale liegen intern auf der CMU.

Der MP3-Konsolenzugang mit Tastatur ist vom Besitzer bestaetigt. Das neue Installerpaket ist noch nicht am Fahrzeug bestaetigt. SSH wird nur bei Auswahl aktiviert. Keine automatische Watchdog-/Opera-/Berechtigungsaenderung. Alte Anleitungen sind kein Firmware-Kompatibilitaetsnachweis.

## Sicherungen

Originale liegen intern unter `/resources/aio-rework/backups/74.00.324A-EU/<vollstaendiger Systempfad>.backup/` mit original und metadata.txt. Neue Sicherungen werden separat vorbereitet, geprueft und dann uebernommen. Vorhandene Originale werden nicht ueberschrieben. Beschaedigte oder unpassende Sicherungen fuehren zum Abbruch.

Eine zweite gepruefte Kopie liegt unter backups/ auf dem Start-USB. Vor dem Dateieingriff muessen beide Kopien passen. USB-Kopien uebernehmen keine Unix-Rechte: FAT32 stellt sie nicht dar. Interne Sicherungen erhalten die Attribute. Keine mitgelieferten alten Ersatzdateien.

Original und installierter Zustand werden per Hash erkannt. Unbekannte Dateien werden nicht ueberschrieben. Ergebnisse werden neben dem Ziel vorbereitet und geprueft, dann per rename uebernommen. Bei fehlgeschlagener Nachpruefung folgt die automatische Ruecknahme zum vorherigen Dateistand. Das ist kein Nachweis fuer Stromausfallsicherheit von relfs.

## Logs immer auf dem Startmedium

Pro Lauf entsteht reports/<Zeit>-<PID>/ mit run.log (stdout/stderr, auch fruehe Fehler), summary.txt (lesbares Ergebnis), status.txt (Exit-Code) und ggf. platform.md5, preflight.txt und before.js. Der Ort folgt dem Paketpfad, unabhaengig vom Arbeitsverzeichnis. Keine interne Ausweichablage fuer Logs.

Ein schreibgeschuetzt eingebundener Start-USB wird fuer Berichte beschreibbar eingebunden. Ist das unmoeglich, folgt ein Abbruch. Nur benoetigte interne Partitionen werden fuer Sicherung/Dateiwechsel beschreibbar eingebunden; ihr vorheriger ro-Zustand wird beim Abschluss wiederhergestellt. Eine Sperre unter /tmp verhindert parallele Installer. SIGKILL oder Stromverlust koennen die Abschlussroutine verhindern.

## Entwicklung und Quellen

catalog.js enthaelt die 41 Gruppen. Listenpiepsen, Listendelay, Hauptmenü im Kreis und SSH sind experimental, die uebrigen sind unported. builder-core.js validiert Projekte/Aktionen und erzeugt ZIPs mit binaeren MP3s. app.js, index.html und styles.css bilden die Oberflaeche. usb/ enthaelt alle Paketquellen.

Die MP3s stammen bytegleich vom zuvor eingelesenen Besitzer-USB. Verwandte Technik: https://github.com/naijamesz/mazda-connect-root-refactor . Keine Schluessel oder persoenlichen Konfigurationen.

Nach USB-Aenderungen: `python web-tools/build-usb-assets.py`. usb-assets.js ist generiert, damit der Browser ohne Fetch/CDN/Server exportieren kann. SHA256 im Manifest dienen der Nachpruefbarkeit, nicht als Signatur. Die CMU-Dateistandspruefung verwendet das vorhandene md5sum.

Tests: `node web-tools/test-web-builder.js` erzeugt ein temporaeres ZIP und meldet den Pfad. Dann:

```text
python web-tools/test-usb-installer.py --zip <ZIP> --original <gesicherte-v74-List2Ctrl.js>
```

Die Shelltests verwenden nur Testkopien mit ersetzten Geraetepfaden und gemockten mount/df/sync. Geprueft werden Install/Uninstall, Full System Restore von neuem Stick, Wiederholung, Defekte, Abbruchfaelle und USB-Logs. Keine realen Mounts oder Fahrzeugzugriffe. Kein visueller Browsertest verfuegbar.

Veroeffentlichung: GitHub Pages aus master/docs. Webentwicklung in web/html-js-builder.


## Gruppen und kombinierbare Patches

Der Katalog ist in Patches & Bedienung, Oberflaeche & Design, Apps sowie System & Diagnose gegliedert. Suche und Pruefstandfilter gelten ueber alle Gruppen. Die Gruppenzuordnung ist Teil der Katalogdaten.

Die gemeinsame Dateiverwaltung benutzt das unveraenderliche interne Original und eine aktive Patchliste. patches/list-beep.sh und patches/shorter-delay.sh erzeugen gezielt gepruefte Textaenderungen auf Arbeitskopien. Install fuegt nur die Auswahl hinzu, Uninstall entfernt nur die Auswahl, Full System Restore entfernt alle von uns verwalteten Aenderungen. Nicht ausgewaehlte aktive Patches bleiben erhalten. Die CMU benoetigt weder diff, patch noch Git.

state.txt liegt neben dem internen Original-Backup und enthaelt Formatversion, aktive Patch-IDs in fester Reihenfolge sowie den zuletzt erzeugten Dateihash. Dieser wird zur Laufzeit berechnet; es gibt keine Tabelle aller Kombinationen. Vor einem Eingriff wird die aktive Variante erneut aus dem Original aufgebaut und mit Zustand und Systemdatei verglichen. Unbekannte Aenderungen fuehren zum Abbruch.

Vor dem Dateiaustausch wird ein transaction-Verzeichnis mit vorherigem und gewuenschtem Zustand geschrieben. Erst nach erfolgreichem Austausch folgt die Zustandsdatei. Ein unterbrochener Vorgang wird beim naechsten schreibenden Aufruf anhand beider rekonstruierter Varianten abgeglichen; bei unbekanntem Inhalt wird keine Systemdatei ueberschrieben. Pruefen meldet einen offenen Vorgang und schreibt keine interne Zustandskorrektur. Das ist eine Wiederanlauflogik, kein Nachweis fuer die Stromausfallsicherheit des CMU-Dateisystems.

Listendelay aendert die vier originalen List2-Zeitparameter von 1500/5000/500/1000 auf 150/300/200/300 ms. Der alte AIO-Kommentar-Marker ist fuer den Zustand nicht erforderlich. Die Kombinationen Original, nur Beep, nur Delay und beide werden separat auf Inhalt und moderne JS-Syntax geprueft; der Fahrzeugtest steht aus.


## SSH Bringback auf v74

Experimentell, kein Fahrzeugtest. Port 22, Benutzer cmu, Passwort jci. Port 36000 des OEM-Diensts bleibt unveraendert. Belegter fremder Port 22 fuehrt vor Einbau des SSH-Boot-Hooks zum Abbruch. Ein eigener vorhandener Dienst wird erkannt.

Die ausgelesene v74-Kontendatei hat bereits cmu mit UID 0, aber ein anderes Passwort. Der neue Dienst setzt deshalb nur zur Laufzeit eine gepruefte RAM-Kopie ueber /config-mfg/passwd. Nur der cmu-Passworthash wird darin ersetzt. Die Flash-Konfiguration wird nicht neu gepackt oder beschrieben. Stop/Uninstall nehmen die Ueberlagerung zurueck; ein Neustart entfernt sie ebenfalls. Das erfordert den nativen bind-Mount und die Authentifizierung auf dem realen Geraet noch zu pruefen.

Der Service nutzt den vorhandenen sshd und den geraeteeigenen RSA-Hostschluessel. Es werden weder persoenliche Client-Schluessel noch private Hostschluessel mitgeliefert/kopiert. SSH-Programme liegen unter /resources/aio-rework/services/ssh, der kleine Boot-Hook in stage_wifi.sh wird ueber dieselbe Original-/Zustandsverwaltung wie die Listen-Patches gesichert und entfernt. Die Firewall wird nur um eine eigene Port-22-Freigabe mit eigener Kette ergaenzt. Ein Hintergrundprozess setzt sie nach Firewall-Neustarts wieder; die OEM-Regeln werden nicht pauschal ersetzt.

Der Dienst lauscht auf allen IPv4-Adressen, auch wenn WLAN erst spaeter verbunden wird. Er verbindet WLAN nicht selbst und aendert keine gespeicherten Netze. stage_wifi ist in der ausgelesenen Startkonfiguration von stage_3 und damit jciMMUI abhaengig. Der Zugang ist deshalb kein garantierter Rettungsweg bei fruehen Boot-/MMUI-Fehlern. Er kann nur starten, wenn diese Startkette, Speicher, SSH-Binary und Netzwerk funktionieren.

Runtime-Ausgaben werden nur auf einen passenden beschreibbaren USB mit mzd/ssh-log-marker.txt geschrieben. Ohne USB oder bei nicht beschreibbarem USB werden sie verworfen; kein Log-Fallback im internen Speicher. PID-Dateien, Kontenueberlagerung und Firewall-Arbeitsdaten in /tmp sind temporaerer Betriebszustand. Entfernen des USB darf den SSH-Dienst nicht beenden.

Verbindung nach Ermitteln der CMU-IP: ssh cmu@CMU_IP. Falls ein aktueller Client den alten RSA-Hostalgorithmus ablehnt: ssh -o HostKeyAlgorithms=+ssh-rsa cmu@CMU_IP. Passwort interaktiv eingeben; keine private Schluesseldatei noetig.

Full System Restore bearbeitet Listen, Hauptmenue und SSH als getrennte Aufgaben. Eine Bestaetigung gilt fuer das Paket. Jede Aufgabe hat eigene Originale, Zustand und Vorgangsdatensaetze. Das Paket ist keine atomare Transaktion ueber alle Aufgaben; Fehler koennen bereits abgeschlossene Teilaufgaben zuruecklassen. summary.txt und die Teilberichte sagen dies ausdruecklich.

Laufzeittest: python web-tools/test-ssh-service.py. Der echte Supervisor laeuft dort mit simulierten netstat/sshd/mount/iptables-Kommandos, ohne echten Netzwerk-Listener oder Kontenaenderung. Installer-Test: python web-tools/test-usb-installer.py --zip <ZIP> --original <List2Ctrl.js> --mainmenu-original <MainMenuCtrl.js>; --ssh-only ueberspringt die umfangreiche List2-Suite. Dort wird ausschliesslich fuer den SSH-Controller ein Dummy-Service benutzt; die Supervisor-Logik wird separat real ausgefuehrt, waehrend Kernel/Daemon-Befehle simuliert sind.

## Hauptmenue im Kreis

Die v74-Originaldatei MainMenuCtrl.js ist bytegleich zur alten v70-Ausgangsdatei. Das bedeutet nicht, dass der Tweak wirkungslos ist: Der Patch aendert in _offsetFocus genau die beiden Begrenzungen (unter 0 auf 4; ueber 4 auf 0). Die alte komplette Ersatzdatei wird nicht kopiert. Normale Listen, Haltezeiten und Layout bleiben unveraendert.

Die Original-Pruefsumme 40ccb293b8c6f80960f0b953dd2e173e und die Ergebnis-Pruefsumme ae272c9befc1350b93f23511568f13c7 begrenzen den Patch auf den geprueften Stand. Eigene Dateigruppe mit Original, Zustand, USB-Zweitkopie und Vorgangsprotokoll; Install/Uninstall/Full System Restore benutzen denselben Manager. Fremde Aenderungen werden abgewiesen.

Funktionstest: node web-tools/test-main-menu-loop.js <lokale MainMenuCtrl.js>. Prueft 20 Original-/Patch-Faelle fuer alle fuenf Positionen und beide Richtungen sowie exakt zwei geaenderte Zeilen. Fahrzeugtest bleibt offen.
