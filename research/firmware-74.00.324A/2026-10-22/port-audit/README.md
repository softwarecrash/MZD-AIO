# Korrigierendes Originaltreue-Audit

Implementierung: [06170bc](https://github.com/softwarecrash/MZD-AIO/commit/06170bc501fc20d117f67fb117dc078742d7d0e4). Vollstaendiger Bericht: [PORT-AUDIT.md](https://github.com/softwarecrash/MZD-AIO/blob/06170bc501fc20d117f67fb117dc078742d7d0e4/docs/PORT-AUDIT.md).

Die fruehere Listen-Kreis-Implementierung mit _aioWrapListFocus ist zurueckgezogen. Der neue Stand uebernimmt ausschliesslich die acht Original-AIO-Einfuegungen in vier bestehenden Handlern. Die vier resultierenden Funktionen sind bytegleich zur alten Tweakvorlage. Alle acht Kombinationen mit Beep/Delay entsprechen ausschliesslich den Originalaenderungen; keine neue Prototype-Methode.

Der selbst geschriebene MP3-Konsoleneinstieg wurde durch die bytegleichen Originaldateien ersetzt. Die zuvor weggelassenen Dateien css/init.css, dev.html und mp3title.txt sind enthalten. Der unabhaengige Vergleich benutzt das gesicherte Originalarchiv und das tatsaechliche ZIP, nicht nur die eigene Assetliste.

232 Originalport-Verhaltensfaelle, 14 Installer-Laeufe und unabhaengiger Archiv-/ZIP-/OEM-/AIO-Vergleich bestanden. SSH-Supervisor-Simulation erneut bestanden; kein Funktionsnachweis am Geraet. Die CMU ist nicht erreichbar.

Der Besitzer hat bestaetigt, dass kein altes Paket installiert wurde, und die Downloadsperre ausdruecklich aufgehoben. Korrigiertes experimentelles Testpaket mit fuenf Auswahlen. SSH bleibt auf seinen ausdruecklichen Wunsch enthalten; echte Anmeldung, Parallelbetrieb, Bootstart und Ruecknahme folgen bei wieder erreichbarer CMU. Die frueheren Freigaben fuer den eigenen Listen-Helfer und die selbst geschriebene MP3-Oberflaeche sind durch dieses Audit ersetzt.
