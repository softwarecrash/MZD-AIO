# Gemeinsam verwaltete List2-Patches

Listenpiepsen und Listendelay sind einzeln und gemeinsam implementiert. Fahrzeugtest offen. Der Web-Katalog ist in Patches & Bedienung, Oberflaeche & Design, Apps und System & Diagnose gruppiert.

Jeder Patch hat ein kleines apply-Skript. Die gemeinsame Verwaltung erzeugt die Zielvariante aus dem geprueften internen Original und allen weiterhin aktiven Patches. Install fuegt die Auswahl hinzu, Uninstall entfernt nur diese Auswahl. Full System Restore setzt die verwaltete Datei auf das Original zurueck. Keine vorberechnete Tabelle aller Kombinationen und keine Abhaengigkeit von diff, patch oder Git auf der CMU.

state.txt neben dem internen Backup speichert die aktive Liste und den zuletzt erzeugten Hash. Vor einer Aenderung werden Original, rekonstruierte aktive Variante, Zustand und Systemdatei abgeglichen. Fremde Aenderungen werden nicht ueberschrieben. Ein persistenter before/after-Vorgangsdatensatz ermoeglicht den Abgleich nach Unterbrechung zwischen Dateiaustausch und Zustandsabschluss. Ein Prueflauf meldet offene Vorgaenge, ohne interne Korrektur.

31 isolierte Integrationslaeufe bestanden; vier JS-Varianten mit modernem Parser syntaktisch geprueft. Einschliesslich getrennter Deinstallation, zweitem Stick und simuliertem Abbruch nach Dateiaustausch. Mounts und Dateisystemkapazitaet wurden simuliert. Kein Fahrzeug-/Stromausfall-/visueller Browsertest.

verification.json verlinkt die festgelegten Quellen und Tests des Web-Branches. Die neue Delay-Regel liegt hier zusaetzlich zur Nachpruefbarkeit. Sie veraendert die vier Zeitparameter 1500/5000/500/1000 in 150/300/200/300 ms, ohne weitere Bedienlogik zu ersetzen.
