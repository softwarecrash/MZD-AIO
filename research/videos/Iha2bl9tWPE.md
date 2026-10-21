# Videoanalyse: MAZDA AIO Tweaks 2024 Updated

Stand: 21.10.2026. Video von Jerry / @XS_ZHAO, veroeffentlicht am 29.08.2024:
https://www.youtube.com/watch?v=Iha2bl9tWPE

## Zugriff und Nachweistiefe

Das automatisch erzeugte englische Transkript konnte diesmal ueber die YouTube-Oberflaeche vollstaendig gelesen werden. Die Videobildspur blieb in dieser Umgebung schwarz; **keine eigene visuelle Kontrolle** der Versionsseite, Checkboxen oder Messwerte. 140 geladene Hauptkommentar-Threads wurden nach Firmware-/Funktionsangaben durchsucht, fuenf relevante Antwortketten geoeffnet. Die Seite nennt insgesamt 329 Kommentare einschliesslich Antworten; kein Anspruch auf vollstaendige Pruefung aller Antworten.

## Ablauf laut Transkript

| Zeit | Befund |
|---|---|
| 00:09–00:47 | MX-5 ND 2018, Firmware v74 NA; Autor lebt in Australien und verwendete eine heruntergeladene NA-Firmware |
| 00:54–01:40 | Eigener Hintergrund und Speedometer beschrieben |
| 04:18–04:43 | Desktop-AIO fuer den Start vom Internet getrennt |
| 04:50–06:20 | Build run.sh aktivieren; ausgewaehlte Tweaks zusammenstellen |
| 08:14–09:30 | In run.sh die Versionsbedingung -eq 70 zu -eq 74 aendern |
| 11:45–13:39 | MP3-Einstieg, Diagnosemenue, Next, Terminal |
| 13:54–15:10 | Generiertes run.sh vom USB starten; Installer AIO 2.8.6 |
| 15:19 | Bisherige eigene Erfahrung: nur etwa zwei Tage |
| 18:26–19:47 | Werksreset / Neustart, danach Anwendungen wieder erreichbar |
| 20:17–21:10 | Bei laufendem Motor Tankstand, Temperatur und zur Motordrehzahl passende Werte berichtet |

Nicht gezeigt bzw. nicht durch das Transkript belegt: ein systematischer Test aller Tweaks, ein SSH-Login, Legacy-AA mit Ton, eine EU-Versionsseite oder langfristige Stabilitaet. Genannte Funktionen und erfolgreiche Installation sind kein pauschaler Testnachweis.

## Konkrete Kommentarspuren

### Firmware des Videos: zusaetzliche Zuschauerangabe
@victorgarmin2311 nennt 74.00.324 NA N als dieselbe Version wie im Video. Das ist eine Zuschauerangabe, keine hier visuell abgelesene Versionsnummer. Seine Antwort verschiebt den eigenen Versuch wegen Ghost Touch; **kein eigener Erfolgsbericht dieses Nutzers**.
https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgyOLe8cQMOfwJ9Q5E94AaABAg

### EU-Erfolg mit spaeterer Rueckmeldung
@Tomi-6GT nennt Mazda6 2019 und 74.00.324A EU. Auf die spaetere Nachfrage bestaetigt derselbe Nutzer Erfolg. Die verwendeten Einzeltweaks und Dateien werden nicht aufgelistet.
https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgyIo0DdnEUBYiFbUoJ4AaABAg

### Touch auf 324 und USB-Hub-Grenze
@JonBOY26 bestaetigt Touch auf einem australischen CX-5 2016 mit 74.00.324. Ein nachgeruesteter USB-C-Port erkannte weder Tastatur noch Stick, auch mit Adapter; verwendet wurde schliesslich der alte USB-A-Hub. Das ist keine Aussage ueber alle OEM-Hubs.
https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=Ugw9T2YClBXINMl4v_94AaABAg

### Negative Rueckmeldungen bleiben relevant
- @leonovdesign: ausgefallener Bildschirm auf 74.00.324, Ursache und Reparatur unbelegt.
  https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgzicNtd1AHICZk7_XJ4AaABAg
- @PerilousGhostt: doppelte AA-Anwendung und Neustarts alle 15–20 Sekunden; eine Antwort behauptet USB-Reparatur, liefert dort aber keine nachvollziehbaren Schritte.
  https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=Ugx30571OPu5SM6Yf_x4AaABAg
- @Kalongauto: Wireless CarPlay nach Installation auf 74.00.331 ausgefallen, keine Loesung in der geoeffneten Antwort.
  https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgzEPW8g3pOKiDyWcPB4AaABAg
- @mariorea9431: MP3-Einstieg auf 74.00.324 EU ohne Terminal. Kein Beweis, dass die Firmware die Luecke generell geschlossen hat.
  https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgzBG2NFzir9qEv_gaR4AaABAg

Der angepinnte Autorenkommentar nennt wechselnde USB-Mountnamen, den Commander-Klick als Enter-Ersatz bei nur einem nutzbaren Datenport und warnt vor Legacy-AA ueber vorhandener OEM-AA/CP-Installation. Diese Warnung nicht zur Behauptung verallgemeinern, jeder solche Versuch verursache zwangslaufig einen Bootloop.
https://www.youtube.com/watch?v=Iha2bl9tWPE&lc=UgxADA1gIXAYE0-GeVB4AaABAg

## Bewertung fuer unseren Rust-Neuaufbau

Die Recherchefrage verschiebt sich von grundsaetzlicher Machbarkeit zur Kompatibilitaet einzelner Aenderungen. Das ist eine wesentlich bessere Ausgangslage: vorhandene Tweaks koennen wiederverwendet werden, sofern konkrete Voraussetzungen und Ruecknahme stimmen.

Der Eingriff an der Versionspruefung erzwingt lediglich einen alten Codepfad. Er passt weder OEM-Dateien noch Hardwareunterschiede automatisch an. Genau dort helfen die geplanten Originaldatei-Exporte: fuer jedes Feature Voraussetzungen, betroffene Dateien und Hashes erfassen; anwendbare Patches gezielt erzeugen; unbekannte Staende nicht pauschal freigeben.

Fuer den Zugang zum Auslesen braucht es keinen AIO-Gesamtinstaller. Der MP3-Terminalweg und ein separat gestarteter SSH-Dienst bleiben getrennt von der spaeteren Tweakinstallation. Der hier untersuchte Videoweg liefert **keinen Funktionstest unseres neuen temporaeren SSH-Skripts**.

Kein Programmcode und kein Tweak wurden aufgrund dieser Videoanalyse uebernommen.
