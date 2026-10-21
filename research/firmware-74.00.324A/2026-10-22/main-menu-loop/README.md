# Hauptmenue im Kreis / 74.00.324A EU

Experimentell, Fahrzeugtest offen. Implementierung: [32ec235](https://github.com/softwarecrash/MZD-AIO/commit/32ec2351fbd1faf1bfa0f7228d68611d36bc0017).

Die v74-Originaldatei MainMenuCtrl.js ist bytegleich zur alten AIO-v70-Ausgangsdatei (MD5 40ccb293b8c6f80960f0b953dd2e173e). Diese Aussage betrifft die Ausgangsdatei, nicht die Wirkung des Tweaks. Der Patch aendert exakt zwei Zeilen in _offsetFocus: unter 0 nach 4, ueber 4 nach 0. Ergebnis-MD5 ae272c9befc1350b93f23511568f13c7. Zusaetzliche Formatierungsaenderungen aus der alten AIO-Ersatzdatei werden nicht uebernommen.

Eigene verwaltete Dateigruppe mainmenu. Unveraenderliches internes Original, USB-Zweitkopie, Zustand und Vorgangsprotokoll verwenden den vorhandenen Dateimanager. Install und Uninstall betreffen nur die Auswahl; Full System Restore schliesst das Hauptmenue unabhaengig von der Builder-Auswahl ein. Fremde Dateiaenderungen werden abgewiesen. Berichte bleiben auf dem Start-USB.

Die 20 Verhaltensfaelle vergleichen Original und Patch fuer alle fuenf Positionen und beide Richtungen. Der Test bestaetigt den Sprung an beiden Enden und normales Verhalten dazwischen. Die komplette Installer-Suite bestand 46 isolierte Laeufe einschliesslich Hauptmenue-Preflight, Install, Wiederholungsinstallation, unveraenderter Originalsicherung, USB-Zweitkopie, Kombination mit beiden Listen-Patches, gezieltem Uninstall, Restore von neuem Stick und Fremdaenderungsabbruch.

Der Web-Builder markiert bei Install jetzt alle vier experimentellen Patches. Unbearbeitete Tweaks bleiben gesperrt. Einzelne Test-Patches koennen abgewaehlt werden. Die urspruenglichen Firmware-Dateien werden hier nicht erneut hochgeladen; Pruefsummen und quellgebundene Nachweise stehen in verification.json.
