# MZD-AIO Web-Builder

Erste statische Seite für einen zukünftigen Builder mit HTML, CSS und JavaScript. Sie benötigt weder Node.js noch einen Build-Schritt und lässt sich direkt mit `index.html` oder über einen statischen Webserver öffnen.

Die Seite zeigt den Entwicklungsstand und kann eine Projektkonfiguration als JSON herunterladen. Tweak-Auswahl, Kompatibilitätsprüfung und USB-Installationspakete sind noch nicht implementiert. Es werden keine Fahrzeugdaten verarbeitet und keine Server-Anfragen für die Konfiguration ausgeführt.

## Lokale Vorschau

Im Repository-Verzeichnis:

```sh
python -m http.server 8765 --bind 127.0.0.1 --directory docs
```

Dann `http://127.0.0.1:8765` im Browser öffnen.

## Dateien

- `index.html`: Struktur und Inhalte
- `styles.css`: responsive Darstellung
- `app.js`: browserlokaler JSON-Export und Eingabeprüfung
- `.nojekyll`: Vorbereitung für statisches GitHub-Pages-Hosting

Der Web-Entwicklungsbranch heißt `web/html-js-builder`. Der Hauptbranch dieses Repositorys heißt derzeit `master`. Für GitHub Pages kann später die Quelle `master` mit dem Ordner `/docs` eingestellt werden. Das Anlegen dieses Ordners allein aktiviert kein Hosting.
