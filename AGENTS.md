# Verbindliche Vorgaben des Besitzers

- Fahrzeug-JavaScript nur gezielt aus nachgewiesenen Original-AIO-Patches portieren. Keine selbst erfundenen Helfer, Handler, Regeln oder sonstigen Verbesserungen ergaenzen.
- Jede Aenderung gegen Firmware-Original und Original-AIO-Tweak vergleichen. Tests muessen auch nachweisen, dass ausserhalb dieser Aenderung nichts hinzugefuegt oder entfernt wurde.
- Den bestaetigten MP3-Konsoleneinstieg einschliesslich aller referenzierten Dateien bytegleich uebernehmen. Nicht durch eine selbst geschriebene Benutzeroberflaeche ersetzen.
- ZIP-Pruefungen gegen die unabhaengige Originalvorlage durchfuehren. Nur gegen selbst erzeugte Assets oder Dateianzahlen zu pruefen reicht nicht.
- SSH ist auf ausdruecklichen Wunsch eine erlaubte eigene Erweiterung. Simulationen sind kein Nachweis einer funktionierenden Anmeldung oder eines funktionierenden Bootstarts auf der CMU. Solche Aussagen benoetigen einen Geraetetest.
- Berichte und Protokolle gehoeren auf das Startmedium. Interne Original-Backups und gezielte Ruecknahme muessen erhalten bleiben.
- Eigene Shell-Skripte verwenden Englisch fuer Meldungen, Rueckfragen, Logs und Kommentare. Die Sprache der Webseite ist davon unabhaengig.
- Die reale CMU hat BusyBox grep ohne -x. Ganze Zeilen portabel mit awk vergleichen; Tests duerfen GNU-grep-Erweiterungen nicht als CMU-kompatibel voraussetzen.
- Der Besitzer hat bestaetigt, dass kein vorheriges Paket installiert wurde, und die Downloadsperre ausdruecklich aufgehoben. Der korrigierte Stand ist ein experimentelles Testpaket fuer ihn. SSH darf enthalten sein; reale Verifikation folgt bei wieder erreichbarer CMU. Diese Freigabe ist kein Fahrzeug-Funktionsnachweis.

Diese Vorgaben betreffen Fahrzeugdateien. Der HTML/JS-Web-Builder und notwendige Installer-Verwaltung bleiben eigene Projektsoftware.

Aktueller Fahrzeugnachweis vom 22.10.2026: Besitzer bestaetigt die fuenf freigegebenen Patch-Funktionen auf 74.00.324A EU. Details und Grenzen in docs/VEHICLE-TESTS.md. SSH-Pfadkorrektur ist Bestandteil des getesteten Stands. Opera-only Restart ist wegen schwarzem Display kein bestaetigter Reload-Weg; Full System Restore und WLAN-off-Boot nicht pauschal als getestet bezeichnen.
