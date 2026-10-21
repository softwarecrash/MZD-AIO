# Firmware- und Funktionsmatrix

Stand 21.10.2026. Diese Matrix ist eine Forschungsübersicht, keine Installationsfreigabe. Regionen und Hardware nicht zusammenfassen.

## Zielprofile und Zugang

| Profil | Stand der Belege | Zugang / offene Arbeit |
|---|---|---|
| 27.xx / 30–42.xx | Nicht in der aktuellen AIO-Kompatibilitätslogik; #12 nennt Bricking-Risiko für v42 | Ein altes Ersatzgerät erst identifizieren. Keinen v55+-Tweak darauf anwenden. |
| 55/56 | Bestehende Installergruppe 1; viele historische Rückberichte | USB-Installationen und SSH unterscheiden; siehe #15/#18/#77. |
| 58 / 59 vor 59.00.502 | Gruppen 2–4, bestehende Firmwarevarianten | Nicht jede Datei ist zwischen Patchständen/Regionen gleich. |
| 59.00.502+ | Gruppe 5; USB-Audio-Mod explizit ausgeschlossen | Historisch vorbereiteter/serieller Zugang, neuere MP3-Methode separat prüfen. |
| 70.00.021 / .100 | Gruppe 6; historische Teilkompatibilität | Legacy-AA und OEM-AA unterscheiden; Audio/USB/Touch regressionsgefährdet. |
| 70.00.335 / .352 | Historisches ID7-/Updatefenster dokumentiert | Genaue Version, Updateweg und vorhandener Zugang entscheidend. |
| 70.00.367 | Altcode Gruppe 7, kein normaler jci-Login nachgewiesen (#135) | MP3-Methode unabhängig vom alten seriellen Login untersuchen. |
| **74.00.311 EU N** | Nutzer nennt alte E-Mail als Hinweis auf den Iststand; noch nicht am Gerät verifiziert | Eigenes Ausgangsprofil und Originaldateien sichern, keine .324-Gleichheit annehmen. |
| **74.00.324 EU** | Geplantes erstes Profil; externe v74-Anleitung, keine eigene Reproduktion | Exakte Versionskennung, Hardware und Originaldateien beschaffen. |
| 74.00.324A 4A N (ADR), CMU150 | Wireless-CarPlay-Ausfall nach AIO in #229 | Eigenes Profil; nicht mit EU gleichsetzen. |
| 74.xx.331 | Wireless-CarPlay-Ausfall in #222 | Eigenes Profil; weder Reparatur noch volle AIO-Kompatibilität belegt. |
| CN BAPK/GW… / andere Connect-Generation | Offene Fragen oder Ablehnung (#69/#105/#208/#227) | Kein EU-Releaseprofil daraus ableiten. |

Die Grenzen in Codekommentaren, Warnungen und älteren Antworten widersprechen sich teils. Die Tabelle normalisiert keine vermuteten Tippfehler zu Fakten.

## Funktionen auf 74.00.324 EU

| Funktion | Aktueller Nachweis | Nächster erforderlicher Test |
|---|---|---|
| MP3 → Diagnose/Terminal | Externer Projektablauf; Code des Diagnoseaufrufs geprüft | Start ohne bleibende Änderungen, exakten Mountpunkt protokollieren |
| SSH-Zugang | Externe Anleitung, Altbausteine ersetzen Konfigurationen | Minimaler Zugang, Netzwerkmodus und unveränderte OEM-Funktionen prüfen |
| Backup/Dateiexport | Als Arbeitsschritt geplant | Leserechte, Symlinks, Modi, Hashes, Dateivollständigkeit |
| Touch im Mazda-Menü | Keine eigene v74-Reproduktion | Einzelpatch; Zustand und Rückbau prüfen |
| Touch in OEM Android Auto | Nicht durch Mazda-Menü-Touch bewiesen (#204) | Separates technisches Thema |
| Touch in CarPlay | Berichte nicht auf alle Profile übertragbar | OEM-Funktion und Anzeige testen |
| Disclaimer / Audioquellen / App-Menü | Altcode ersetzt systemApp.js | Minimaldiff gegen genaue v74-Datei; CP-Symbol/WLAN berücksichtigen |
| Speedometer/Statusbar | Historische Fixes vorhanden | Datenzugriff, Nullwerte, Einheiten, CSS und Lifecycle |
| WLAN-AP | Desktop-Kompilierfixkandidat #230 | Bringup, BT-Koexistenz, OEM-Wireless-CarPlay und Rückbau |
| Legacy Android-Auto-Headunit | Bereits v70 problematisch | Separates Projekt-/ABI-/Audioaudit; nicht Teil des ersten Basisprofils |
| Video/Castscreen | Historische GStreamer-/Surface-Hinweise | Nur nach Kamera-/Kontextwechselprüfung |
| Full Restore | Historischer Bootloop-Bericht | Kein Standardweg; erst Wiederherstellung am Ersatzgerät beweisen |

Ein erfolgreiches `run.sh` oder der Bezeichner „installed“ im Log ersetzt keinen Funktionstest.

## Versionsstand zur konkreten Nutzerfrage

74.00.311 EU N ist nicht der letzte öffentlich belegte reguläre EU-Stand: 74.00.324 EU N / 74.00.324A EU N ist später dokumentiert. Quelle: [ASH8, Originalbeitrag vom 11.04.2023](https://forum.miata.net/vb/showthread.php?page=83&t=679114), ergänzend [EU-Updatebericht 2022](https://www.cx5-forum.de/threads/mzd-firmware-74-00-324-eu.12745/). Beim Recherchelauf am 21.10.2026 wurde kein neuerer regulärer EU-Stand belastbar belegt. Das ist keine Abfrage eines internen Mazda-Händlerkatalogs. 74.00.331-Berichte anderer Regionen werden nicht als neuerer EU-Release ausgegeben. Ein Update wurde weder beauftragt noch ausgeführt.
