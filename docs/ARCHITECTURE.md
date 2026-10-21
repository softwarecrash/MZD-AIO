# Spaeterer Ausbau: AIO-App als Zentrale

Status: Entwurf aus der Abstimmung vom 22.10.2026, keine bereits implementierte App-Erweiterung. Der aktuelle Auftrag bleibt der SSH-Tweak.

Ziel: Einmal die AIO-App per USB installieren, danach Patches auf dem Mazda-Bildschirm verwalten. Neue Funktionen kommen ueber ein USB-Update der App. Der Web-Builder bleibt fuer Erstinstallation, Wiederherstellung und Vorbereitung von Update-Paketen nutzbar.

## Ein gemeinsamer Ordner in /resources

Alle eigenen persistenten Dateien gehoeren unter einen gemeinsamen Root (aktuell /resources/aio-rework): app/, engine/, patches/, services/, state/, backups/ und updates/. Original-Backups und Nutzerdaten liegen ausserhalb austauschbarer App-Versionen. Notwendige OEM-Menueeintraege und Boot-Verweise bleiben kleine, dokumentierte und ruecknehmbare Hooks ausserhalb dieses Ordners. Es darf keine zweite unabhaengige Patchlogik in der App entstehen.

Die App bedient dieselben bekannten Patch-IDs und Aktionen wie der Installer: Status, Install, Uninstall, Full System Restore. Ein lokaler Backend-Zugang akzeptiert nur diese definierten Aktionen. Das alte Netzwerk-WebSocket-zu-Shell-Modell wird nicht einfach als Fernsteuerung uebernommen.

## Update vom USB

Update-Paket mit Version, Firmware-Ziel und Dateimanifest pruefen, getrennt vorbereiten, dann auf die neue Version umschalten. Die vorherige Version bleibt fuer Ruecknahme erhalten. Backups, Zustand und Einstellungen werden nicht durch App-Payloads ueberschrieben. Aenderungen des Zustandsformats brauchen eine ausdrueckliche, ruecknehmbare Migration; alte Patchdefinitionen duerfen nicht kommentarlos verschwinden.

## Noch offene Produktentscheidungen

Der heutige Installer verlangt einen beschreibbaren Start-USB fuer Protokolle und die zweite Backupkopie. Eine spaetere Bedienung ganz ohne USB benoetigt eine bewusst abgestimmte Anpassung dieser Vorgabe, statt stillschweigend interne Logs anzulegen. Interne gepruefte Originale bleiben Voraussetzung; der USB kann als Export-/Update-/Recovery-Medium dienen. Die genaue Log-/Exportbedienung bleibt offen.

Eine GUI-App kann sich bei einer defekten GUI nicht selbst reparieren. USB-Wiederherstellung und der getrennte SSH-Zugang bleiben deshalb zusaetzliche Wege, sofern Bootpfad und Netzwerk noch funktionieren. Einige Systemaenderungen brauchen weiterhin einen Neustart.
