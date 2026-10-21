**ZURUECKGEZOGEN:** Dieser historische Stand mit eigener Hilfsfunktion wurde im [Originaltreue-Audit](../port-audit/README.md) verworfen. Nicht als aktuelle Portierung verwenden.

# Listen im Kreis / 74.00.324A EU

Experimentell, Fahrzeugtest offen. Implementierung: [82e1baf](https://github.com/softwarecrash/MZD-AIO/commit/82e1baf41bbe224c9771762db59674106d99bdc8).

Der alte AIO-Tweak ergaenzt vier Commander-Handler in List2Ctrl.js fuer Drehen und Kippen. Statt die alte komplette Ersatzdatei zu kopieren, fuegt der Rework gezielt eine gemeinsame ES5-Hilfsmethode und die vier Aufrufe hinzu. Die Originaldatei bleibt die Grundlage fuer alle aktiven Patches.

Kreissprung nur bei unveraendertem Fokus und wenn in der bisherigen Richtung kein weiterer aktivierter Eintrag folgt. Deaktivierte Eintraege am gegenueberliegenden Ende werden uebersprungen. Ein stehender Fokus am Rand des sichtbaren Listenausschnitts bleibt normales Scrollen, solange weitere aktive Eintraege folgen. Kein Sprung bei leeren/unvollstaendigen Listen, Buchstabenindex, Umsortieren, Touch oder gesperrtem Laden. Die vorherige pauschale 'Fokus hat sich nicht bewegt'-Logik allein waere am Ausschnittrand zu breit.

Die Reihenfolge bleibt Listenpiepsen, Listendelay, danach Listen im Kreis. Bisherige Beep-/Delay-Zustandsdateien bleiben bytegleich kompatibel. Der gemeinsame Original-/Zustandsmanager entfernt beim Uninstall nur die Auswahl und rekonstruiert die anderen aktiven Patches unveraendert. Keine zusaetzlichen Laufzeit-Tabellen aller Kombinationen und kein diff/patch auf dem Geraet.

Offline bestanden: 256 Verhaltensfaelle ueber acht Kombinationen; Strukturfehler und erneutes Anwenden werden abgewiesen. Die 14 gezielten Installer-Laeufe durchlaufen alle acht Zustaende, Hinzufuegen/Entfernen einzelner Patches, alte Beep-/Delay-Zustaende, unveraenderliche Originale, USB-Zweitkopie, Restore von einem neuen Stick und Abbruch bei Fremdaenderungen. Die Funktionstests simulieren die Fokus-/Scrollgrenze; sie ersetzen keinen realen GUI-Test. Die allgemeine 46-Laeufe-Suite wurde beim unmittelbar vorherigen Hauptmenue-Port bestanden; fuer diesen Patch wurde gezielt die neue gemeinsame List2-Kombinatorik getestet.

Der Builder waehlt bei Install jetzt alle fuenf experimentellen Test-Patches aus. Originaldateien und erzeugte Kombinationen werden hier nicht erneut hochgeladen; verification.json enthaelt nur Pruefsummen und Quellnachweise.
