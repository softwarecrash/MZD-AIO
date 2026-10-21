# Originaltreue-Audit vom 22.10.2026

**USB-Download gesperrt.** Dieser Bericht ersetzt die vorherigen Paketfreigaben. Die CMU ist nicht erreichbar; es wurde nichts am Fahrzeug geaendert.

## Ursache

Die bisherigen ZIP-Pruefungen verglichen das Paket ueberwiegend mit der selbst zusammengestellten Assetliste. Diese Liste war bereits unvollstaendig. Dadurch konnten Dateianzahl, CRC und Hashvergleiche bestehen, obwohl kein vollstaendiger Original-MP3-Einstieg enthalten war. Die selbst geschriebene Konsolenoberflaeche war zudem kein Nachweis fuer den bestaetigten Einstieg.

Beim Listen-Kreistweak wurde eigenmaechtig eine neue Methode `_aioWrapListFocus` mit zusaetzlichen Regeln eingebaut. Die damaligen Funktionstests prueften diese eigene Implementierung und bewiesen keine Originaltreue. Diese Methode und die darauf bezogene Freigabe sind zurueckgezogen.

## Vollstaendiger Umfang der Fahrzeugaenderungen

| Datei / Bereich | Tatsaechliche Aenderung | Audit und Korrektur |
| --- | --- | --- |
| `/jci/gui/common/controls/List2/js/List2Ctrl.js`, Listenpiepsen | Zwei lange Commander-Pieptoene auskommentiert | Entspricht exakt dem aktiven sed-Befehl in `07_listbeep-i.txt`. Keine weiteren Tonfunktionen entfernt. |
| Dieselbe Datei, Listendelay | Vier Werte: 1500/5000/500/1000 nach 150/300/200/300 | Entspricht den vier Befehlen in `07_shorterdelay-i.txt`. Nur dessen informeller Kommentar-Marker wird weggelassen, weil der Installer einen separaten Zustand fuehrt. Kein zusaetzliches Laufzeitverhalten. |
| Dieselbe Datei, Listen im Kreis | Zuvor eigener Helfer und vier Aufrufe | Eigener Helfer entfernt. Jetzt ausschliesslich die acht Einfuegungen aus dem alten AIO-Tweak in vier bestehenden Handlern. Deren resultierende Funktionskoerper sind bytegleich zur Original-AIO-Vorlage. Keine neue Prototype-Methode. |
| `/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js` | Zwei Grenzwerte in `_offsetFocus` | Entspricht exakt der Funktion im Original-AIO-Tweak. Keine weiteren Methoden, Layout- oder Zeitveraenderungen. Zusaetzliche Formatierungsunterschiede der alten Ersatzdatei werden nicht uebernommen. |
| `/jci/scripts/stage_wifi.sh` | Zwei Zeilen fuer eigenen SSH-Start | Kein Original-AIO-Port, sondern eigener SSH-Boot-Hook. Auf ausdruecklichen Wunsch bleibt die SSH-Erweiterung erhalten. Geraetenachweis fehlt; neue Installation gesperrt. |
| `/config-mfg/passwd` bei aktivem SSH | RAM-Kopie per bind mount; nur cmu-Hash ersetzt | Eigene SSH-Implementierung, keine uebernommene AIO-Methode. Kein Flash-Neupacken. Tatsachlicher Mount und Anmeldung auf CMU unbestaetigt. |
| Firewall bei aktivem SSH | Eigene TCP-22-Kette und Ueberwachung | Eigene SSH-Implementierung. OEM-Datei `/jci/scripts/jci-fw.sh` wird nicht gepatcht. Reales WLAN-/Firewall-Verhalten unbestaetigt. |
| SSH-Konfiguration | Eigene Datei unter `/resources/aio-rework/services/ssh` | OEM-`sshd_config` und private OEM-Hostschluessel werden nicht ersetzt. Port 36000 bleibt in der Implementierung unveraendert; realer Parallelbetrieb noch offen. |
| USB `js/run.js` | Zuvor selbst geschriebene Ersatzoberflaeche | Entfernt und bytegleich aus dem gesicherten Original-USB-Archiv wiederhergestellt. Auch die Bedienelemente stammen wieder aus diesem Original. |
| USB `css/init.css`, `dev.html`, `mp3title.txt` | Im bisherigen Paket weggelassen | Aus demselben Originalarchiv ergaenzt. Alle acht MP3-Einstiegsdateien sind nun bytegleich, einschliesslich ihrer originalen Zeilenenden. |

Die acht MP3-Einstiegsdateien sind vier MP3s, `js/run.js`, `css/init.css`, `dev.html` und `mp3title.txt`. Die im Archiv ebenfalls enthaltenen `start-ssh.sh` und der persoenliche oeffentliche Schluessel `mazda.pub` gehoeren zum separaten manuellen SSH-Test und werden vom MP3-/Konsoleneinstieg nicht referenziert. Sie werden nicht in das allgemeine Paket uebernommen.

Weitere OEM-Dateien werden durch die bisher implementierten Patches nicht beschrieben. `startSystemScripts.sh` und `run-terminal.sh` werden nur per Pruefsumme geprueft. Binaerdateien, Bibliotheken und JSON-Systemdateien werden nicht gepatcht. Neue Installer-, Backup-, Zustands- und Berichtsdateien sind eigene Projektverwaltung; diese war ausdruecklich beauftragt und ist keine Erweiterung der OEM-JavaScript-Funktionen.

## Unabhaengige Nachweise

- `mp3-reference.json` enthaelt Hash und Dateiwerte aus dem gesicherten Originalarchiv. Der Assetgenerator bricht bei fehlenden oder veraenderten Einstiegdateien ab.
- `test-port-audit.py` vergleicht das tatsaechlich erzeugte ZIP mit dem unabhaengigen Originalarchiv und prueft die darin referenzierten Skript-/CSS-/HTML-Dateien.
- Derselbe Test vergleicht alle acht List2-Kombinationen gegen die Firmware und die alten AIO-Quellen. Ausserhalb der nachgewiesenen AIO-Aenderungen muss die Datei vollstaendig identisch bleiben. Die Prototype-Liste darf nicht wachsen.
- Hauptmenue: exakter Dateivergleich mit nur den zwei AIO-Grenzaenderungen und identische `_offsetFocus`-Funktion.
- 232 aktuelle Verhaltensfaelle pruefen die Originalportierung; 14 aktuelle Installer-Laeufe pruefen Kombinationen, selektive Ruecknahme, unveraenderliche Originale, neuen Restore-Stick und Fremdaenderungsabbruch.

Die Original-AIO-Listenlogik wird nicht still verbessert. Insbesondere wird ihr Verhalten bei stehengebliebenem Fokus beibehalten. Die frueheren Aussagen ueber zusaetzliche Absicherungen des eigenen Helfers gelten nicht fuer diesen Originalport.

## Offene Freigabepunkte

1. Ein bereits installiertes Paket mit dem verworfenen eigenen Listen-Helfer hat andere Dateihashes. Die korrigierte Portierung darf diesen Stand nicht als unveraendert akzeptieren oder blind ueberschreiben. Eine explizit gepruefte Ruecknahme dieser Altstaende steht aus. Deshalb bleibt der allgemeine ZIP-Download gesperrt.
2. SSH ist auf Wunsch erhalten, aber die CMU ist nicht erreichbar. Simulationen belegen keine echte Passwortanmeldung, keinen funktionierenden Boot-Hook und keine tatsaechliche Kontenueberlagerung. Solange diese Geraetetests fehlen, bleibt SSH aus der neuen Installationsauswahl genommen.

Maschinenlesbarer Nachweis: [port-audit.json](port-audit.json). Dauerhafte Arbeitsvorgaben: [AGENTS.md](../AGENTS.md).
