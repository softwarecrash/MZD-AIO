# Erster v74-Port: Listenpiepsen deaktivieren

Status: experimentell, offline geprueft; Fahrzeugtest offen. Zwei Long/Multicontroller-Beep-Aufrufe in der originalen v74-List2Ctrl.js werden auskommentiert. Keine Ersetzung durch eine alte Gesamtdatei.

Der Web-Builder erzeugt Install-, Uninstall- und Full-System-Restore-Pakete mit MP3-Konsoleneinstieg und tweaks.sh. restore.sh ist die zusaetzliche vollstaendige Ruecknahme ohne Builder-Auswahl. Beide pruefen Firmware und bekannte Dateistaende. Full System Restore betrifft derzeit nur diese von uns verwaltete Datei; kein Werksreset oder Restore fremder AIO-Versionen.

Originale bleiben intern in /resources mit vollem Pfad und Firmwarezuordnung erhalten. Vor Dateiaenderungen werden sie sowie die zusaetzliche USB-Kopie geprueft. Neue USB-Sticks koennen aus der internen Sicherung wiederherstellen. Logs und Berichte bleiben auf dem Start-USB. Kein automatischer Neustart.

manifest.json dokumentiert Original-/Patchhashes, Sicherungspfade und den festgelegten Implementierungscommit des Web-Branches. Die ausfuehrbaren Quellen und Tests sind dort verlinkt; hier wird nur die eigentliche kleine Patchregel zusaetzlich abgelegt. verification.json dokumentiert die 21 bestandenen isolierten Integrationslaeufe und deren Grenzen. Test-Mounts, df und sync wurden simuliert; kein Fahrzeugzugriff und kein Stromausfalltest.

Die bestehende Legacy-Anwendung wurde durch diesen Port nicht geaendert. Weitere Tweaks werden einzeln portiert. Neue Apps sollen standardmaessig auf /resources liegen; dieser Patch bearbeitet eine bestehende Systemdatei an ihrem Originalort.
