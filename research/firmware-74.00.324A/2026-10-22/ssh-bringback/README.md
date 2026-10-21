# SSH Bringback: Firmware 74.00.324A EU

Stand 22.10.2026: experimentell, kein Fahrzeugtest. Implementierung: [5a279b1](https://github.com/softwarecrash/MZD-AIO/commit/5a279b18636896f51c5c48bd5b2622d6cfb4d9cf). SHA256-Quellnachweise und Testumfang: verification.json.

## Verhalten

Eigener nativer SSH-Dienst auf Port 22, Anmeldung cmu / jci. OEM-Port 36000 bleibt bestehen. Ein fremder Listener auf Port 22 verhindert die Installation des SSH-Boot-Hooks. Wiederholte eigene Starts erzeugen keinen zweiten Listener. WLAN-Verbindungen und gespeicherte Netze werden nicht eingerichtet oder veraendert.

Die ausgelesene Firmware besitzt cmu mit UID 0 und /bin/sh, jedoch nicht das Passwort jci. Nur der cmu-Hash wird in einer RAM-Kopie von /config-mfg/passwd ersetzt und per bind mount eingeblendet. Stop/Uninstall entfernen diese Ueberlagerung; keine Neuschreibung der Manufacturing-Flashdaten. Der vorhandene geraeteeigene RSA-Hostschluessel wird benutzt. Keine privaten Schluessel oder ausgelesenen Kontendateien sind enthalten.

Payload: /resources/aio-rework/services/ssh. Original-Backup und Zustand: /resources/aio-rework/backups/74.00.324A-EU/jci/scripts/stage_wifi.sh.backup/. Der kleine stage_wifi-Hook benutzt denselben Original-/Patchlisten-/Vorgangsmanager wie die Listen-Patches. Full System Restore ignoriert die Builder-Auswahl und bearbeitet beide Dateigruppen. Die Aufgaben bilden keine atomare Gesamttransaktion; Teilberichte zeigen bereits abgeschlossene Aenderungen.

Eigene Firewall-Kette fuer TCP 22; ein Supervisor setzt die Freigabe nach OEM-Firewall-Neustarts erneut. Runtime-Logs gehen ausschliesslich auf einen passenden beschreibbaren USB; ohne diesen werden sie verworfen. /tmp enthaelt nur temporaeren Betriebszustand und die Kontenkopie.

## Grenzen und naechster Fahrzeugtest

SM-Konfiguration: stage_wifi haengt von stage_3 und damit jciMMUI ab. Kein garantierter Rettungszugang bei fruehen Boot-/MMUI-Fehlern. Am Fahrzeug zu pruefen: nativer sshd-Konfigurationstest, bind mount der Kontendatei, Passwortanmeldung, Neustart/WLAN erst nach Dienststart, Firewall-Neustart, USB-Entfernung und Uninstall/Full System Restore. Offline-Ergebnisse beweisen diese Geraeteeigenschaften nicht.

Die vollstaendige Installer-Suite bestand 38 isolierte Laeufe; die anschliessende gezielte SSH-Suite bestand 8 Laeufe einschliesslich der Pruefung des bereits installierten Diensts. Der reale Supervisor wurde mit simulierten Kernel-/Daemon-Kommandos getestet. Web-Builder und erzeugtes ZIP wurden separat geprueft. Details und Grenzen stehen in verification.json.

## Spaetere AIO-Zentrale

[Architekturentwurf](https://github.com/softwarecrash/MZD-AIO/blob/5a279b18636896f51c5c48bd5b2622d6cfb4d9cf/docs/ARCHITECTURE.md): gemeinsame Patchlogik, ein Root in /resources, getrennte unveraenderliche Backups, App-Updates vom USB. Das ist ein Plan fuer spaeter; eine steuernde AIO-App wurde noch nicht implementiert.
