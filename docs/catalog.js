globalThis.MZD_CATALOG = [
  {
    "id": "background",
    "title": "Hintergrundbild",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Bildziele vorhanden; Bildformat und echte Original-Backups je Ziel sichern. Kein Fahrzeug-/Renderingtest.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "background-rotation",
    "title": "Wechselnde Hintergründe",
    "auditStatus": "CSS_KANDIDAT",
    "description": "Ergänzt markiertes CSS. CSS-Marker und Rücknahme je Feature isolieren; Bild-/Animationsdarstellung ist offen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "multicontroller",
    "title": "Multicontroller",
    "auditStatus": "NICHT_UNVERAENDERT",
    "description": "Nach dem Kopieren steht am Ende ein unbedingtes restore_org desselben Multicontroller.js. Bei erfolgreichem Backup wird die Änderung sofort rückgängig gemacht.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "reconnect-message",
    "title": "Verbindungshinweis ausblenden",
    "auditStatus": "TEXT_KANDIDAT",
    "description": "Zielstelle trifft; guard-modellierte zweite Anwendung bleibt unverändert, erzeugtes JavaScript ist syntaktisch gültig. Laufzeitsemantik des Dialogereignisses offen; kein eigenes -u-Skript.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "sd-cid",
    "title": "SD-Kartenkennung",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Zusätzliches natives Hilfsprogramm; Architektur, Laufzeit und SD-Zustände nicht ausgeführt/geprüft.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "system"
  },
  {
    "id": "ssh-bringback",
    "title": "SSH-Zugang",
    "auditStatus": "NICHT_UNVERAENDERT",
    "description": "Aktiviert einen SSH-Zugang auf Port 22 für den Zugriff per Netzwerk, auch nach einem Neustart. Anmeldung: cmu / jci. Eigene Erweiterung; Anmeldung, Parallelbetrieb und Bootstart müssen noch an der CMU getestet werden.",
    "selectable": true,
    "releaseStatus": "experimental",
    "category": "system",
    "vehicleTested": false
  },
  {
    "id": "storage",
    "title": "Speicheranpassung",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Opera-Persistenzdateien und Links sind zustandsabhängig. Kein Test der Browserdatenmigration oder Rücknahme vorhandener Daten.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "system"
  },
  {
    "id": "wifi",
    "title": "WLAN",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Ändert Netzwerkkonfiguration; bestehende v74-/Wireless-CarPlay-Nutzung und Rücknahme nicht auf dem Gerät geprüft.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "system"
  },
  {
    "id": "aio-app",
    "title": "AIO-App",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Benötigt zusätzliche Apps, UserJS und Startintegration. Dateipfade allein beweisen keine funktionierende v74-App-Laufzeit.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "casdk-node",
    "title": "CASDK / Node",
    "auditStatus": "ANPASSEN",
    "description": "Startskripte, Proxys, Ressourcen und App-Liste. Alte systemApp-Ersetzungen verlieren v74-Methoden; neue Integration und native Abhängigkeiten getrennt prüfen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "touchscreen",
    "title": "Touchscreen während der Fahrt",
    "auditStatus": "ANPASSEN",
    "description": "Common.js-Textkomponente trifft, ist guard-modelliert idempotent und per direktem Uninstall-sed bytegenau rücknehmbar. Zusätzlich verändern die OEM-Helfer NVRAM-/LVDS-Zustände; diese und DVD-D-Bus wurden nicht getestet.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "disclaimer",
    "title": "Start-Hinweis",
    "auditStatus": "NICHT_UNVERAENDERT",
    "description": "Verwendet vollständige ältere systemApp-Dateien bzw. cat-Zusammenbau. v74-WCP-/Menülogik erhalten; als gezielten Patch neu implementieren.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "camera-warning",
    "title": "Kamerahinweis",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Ersetzt Bilder; Installationssnippet besitzt keine backup_org-Aufrufe. Für v74 reale Bild-Originale statt pauschaler Altgrafiken zurückspielen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "parking-sensors",
    "title": "Parksensor-Grafiken",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Ersetzt Gruppen von Bildern; keine individuellen Original-Backups im Installationssnippet. Grafikformate, Sensorvarianten und Rücknahme offen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "main-menu-loop",
    "title": "Hauptmenü im Kreis",
    "auditStatus": "ANPASSEN",
    "description": "Lässt die Auswahl im Hauptmenü vom letzten Symbol zum ersten und umgekehrt springen. Ändert gezielt nur die beiden Grenzen der Auswahl; normale Listen bleiben unverändert.",
    "selectable": true,
    "releaseStatus": "experimental",
    "category": "patches",
    "vehicleTested": false
  },
  {
    "id": "list-loop",
    "title": "Listen im Kreis",
    "auditStatus": "ANPASSEN",
    "description": "Lässt die Auswahl in unterstützten Listen beim Drehen oder Kippen des Commanders vom letzten Eintrag zum ersten und umgekehrt springen. Mit Listenpiepsen und Listenverzögerung kombinierbar.",
    "selectable": true,
    "releaseStatus": "experimental",
    "category": "patches",
    "vehicleTested": false
  },
  {
    "id": "list-beep",
    "title": "Listenpiepsen deaktivieren",
    "auditStatus": "TEXT_KANDIDAT",
    "description": "Schaltet den Signalton bei bestimmten langen Multicontroller-Aktionen in Listen aus. Andere Systemtöne bleiben erhalten.",
    "selectable": true,
    "releaseStatus": "experimental",
    "vehicleTested": false,
    "category": "patches"
  },
  {
    "id": "shorter-delay",
    "title": "Kürzere Listenverzögerung",
    "auditStatus": "TEXT_KANDIDAT",
    "description": "Verkürzt Wartezeiten beim automatischen Scrollen in Listen. Kann zusammen mit dem Listenpiepsen-Patch verwendet und einzeln entfernt werden.",
    "selectable": true,
    "releaseStatus": "experimental",
    "category": "patches",
    "vehicleTested": false
  },
  {
    "id": "system-beep",
    "title": "Systemtöne deaktivieren",
    "auditStatus": "TEXT_KANDIDAT",
    "description": "Die system/PlayAudioBeep-Zielstelle trifft, audiosettings-Alternative trifft nicht und ist eine alternative Verzweigung. Markierungs-Guard ist idempotent; Syntax geprüft. Kompletter Uninstall noch nicht simuliert.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "audio-source-order",
    "title": "Reihenfolge der Audioquellen",
    "auditStatus": "NICHT_UNVERAENDERT",
    "description": "cat-Zusammenbau ersetzt systemApp aus 59/70-Vorlagen, einschließlich kombinierter Disclaimer-Varianten. Neue WCP-Einträge und Ereignisse müssen erhalten bleiben.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "message-replies",
    "title": "Nachrichten-Antworten",
    "auditStatus": "ANPASSEN",
    "description": "Ersetzt Konfigurations-XML und verlangt Factory Reset; entfernt ggf. input_filter aus sm.conf ohne backup_org für sm.conf in diesem Snippet. Einstellungs-/Datenreset ist kein durch Text-Rollback vollständig rücknehmbarer Schritt.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "diagnostic-entry",
    "title": "Diagnosezugang",
    "auditStatus": "ANPASSEN",
    "description": "Die drei kleinen Eingriffsstellen treffen und sind guard-modelliert idempotent/syntaktisch gültig. Anschließendes Kopieren der alten Test-Steuerelemente entfernt aber setUblox aus dem v74-TestCtrl.js.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "system"
  },
  {
    "id": "boot-animation",
    "title": "Startanimation",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Variantenabhängige IVF-Dateiersetzungen mit Loop-/Transition-Zielen; Dateien vorhanden, Decoder-/Auflösungsprüfung und Fahrzeugstarttest nicht ausgeführt.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "bigger-album-art",
    "title": "Größeres Albumcover",
    "auditStatus": "ANPASSEN",
    "description": "CSS wird ergänzt; zwei Rahmenbilder werden zusätzlich ersetzt. Uninstall entfernt primär CSS und stellt diese Bilder nicht wieder her; Image-Backups/Rücknahme ergänzen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "button-backgrounds",
    "title": "Schaltflächen-Hintergründe",
    "auditStatus": "CSS_KANDIDAT",
    "description": "Markiertes CSS in Ump3Ctrl.css; Optionen und gemeinsame Marker mit anderen UI-Tweaks müssen kombiniert getestet werden. Keine UI-Renderingprüfung.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "blank-art-frame",
    "title": "Albumrahmen ausblenden",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Drei Bilddateien werden ersetzt, Uninstall kopiert mitgelieferte config_org-Grafiken statt geräteeigener Backups. Hashgebundene Originale je Datei erforderlich.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "video-player",
    "title": "Videoplayer",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Startet websocketd mit Shell und installiert GStreamer-/FLAC-Bibliotheken. ABI, Netzwerkzugriff, Player und Bibliotheksabhängigkeiten nicht ausgeführt.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "swapfile",
    "title": "Swap-Datei",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Benötigt USB-Speicher-/Dateisystem-/Swap-Zustände und Startintegration. Diese Eigenschaften lassen sich aus den Firmwaredateien nicht freigeben.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "system"
  },
  {
    "id": "speedometer",
    "title": "Tacho-App",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Gemeinsamer Prüfbereich einschließlich Sprach-/Anzeigeoptionen: installiert App und Websocket-/Shell-Startpfad; Fahrzeugdatenquellen und vollständige Optionen-Laufzeit offen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "date-statusbar",
    "title": "Datum in der Statusleiste",
    "auditStatus": "ANPASSEN",
    "description": "Ersetzt StatusBarCtrl.js/Utility.js mit Altvorlagen. v1 entfernt sechs erkannte OEM-Methoden; v3 behält Methodennamen, kann aber veränderte CP/AA-Methodenkörper überschreiben. Sicherer v74-Eingriff muss kleiner werden.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "main-menu-style",
    "title": "Hauptmenü gestalten",
    "auditStatus": "CSS_KANDIDAT",
    "description": "Markierte CSS-Ergänzungen; v74-MainMenu-CSS ist bytegleich zur v70-Vorlage. Varianten, benutzerdefinierte Farben und Kombinationen visuell prüfen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "statusbar-style",
    "title": "Statusleiste gestalten",
    "auditStatus": "CSS_KANDIDAT",
    "description": "Farb-/Transparenz-CSS wird ergänzt. Generische MZD-AIO-TI-CSS-Marker sind mit anderen CSS-Tweaks geteilt; Rücknahme und Reihenfolge isolieren.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "ui-style",
    "title": "Oberfläche gestalten",
    "auditStatus": "CSS_KANDIDAT",
    "description": "CSS-Ergänzungen und Löschen bestimmter Animationsregeln. Keine pauschale Ersetzung erforderlich, aber Selektoren/Kombinationen und UI-Wirkung offen.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "colors-theme",
    "title": "Farben und Themes",
    "auditStatus": "ASSET_PRUEFUNG",
    "description": "Kopiert ganze themenabhängige jci-Bäume und ggf. Navigations-UX-ZIP. Gewählte Payloads und überschriebenen Umfang vor Generierung vollständig begrenzen und sichern.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "ui"
  },
  {
    "id": "fuel-consumption",
    "title": "Verbrauchsanzeige",
    "auditStatus": "ANPASSEN",
    "description": "JS/CSS der v74-Verbrauchsanzeige sind bytegleich zu AIO-v70. Die Tweak-Payload entfernt keine erkannten Methoden, ersetzt aber ganze Dateien und Bild; Einheiten und Sicherung aller drei Ziele gezielt portieren.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "patches"
  },
  {
    "id": "castscreen",
    "title": "Bildschirmübertragung",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Native Empfangs-/Startprogramme und ggf. Bibliotheken; ABI, Smartphone-/USB-Verbindung und Laufzeit nicht getestet.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "legacy-android-auto",
    "title": "Altes Android Auto",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Alte headunit-/Audio-/Startintegration zusätzlich zur vorhandenen OEM-AA-Implementierung. Keine Laufzeit-/Audio-/USB-Freigabe allein aus Dateiproben ableiten.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  },
  {
    "id": "mzd-meter",
    "title": "MZD-Meter",
    "auditStatus": "LAUFZEIT_OFFEN",
    "description": "Zusätzliche App, native Dateien und watch-/Shell-Startpfad; Schnittstellen und Laufzeit noch nicht validiert.",
    "selectable": true,
    "releaseStatus": "unported",
    "category": "apps"
  }
];
