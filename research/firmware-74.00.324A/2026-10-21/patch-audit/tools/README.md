# Lokale Wiederholung

Python 3, Git und GNU sed werden benoetigt; der Komponententest zusaetzlich Bash. Standardpfade sind Git for Windows; andere Programme ueber --sed bzw. --bash setzen.

Vom lokalen Arbeitsverzeichnis mit vorhandener privater Sicherung aus:

```powershell
python <patch-audit>/tools/audit_aio_patches.py --repo MZD-AIO-rework --tweaks aio_reference/app/files/tweaks --backup mcu_backup_20261021_203342 --fixtures patch_audit_work --output audit-output
python <patch-audit>/tools/check_aio_components.py --fixtures patch_audit_work --tweaks aio_reference/app/files/tweaks --output audit-output
```

`<patch-audit>` durch den Pfad dieses Berichts ersetzen. Der Referenzbaum muss zum im summary.json dokumentierten Fork-Commit passen; der erste Lauf prueft die Git-Blob-Hashes. Private Archive und extrahierte Fixtures bleiben lokal. Die Werkzeuge fuehren keine kompletten Installer aus.

Die JavaScript-Syntaxbelege wurden separat mit Node vm.Script erzeugt: jeweils Originaldatei und geaenderte Fixture kompilieren, ohne den Code auszufuehren. Die Fixture-Listen syntax-cases.json und component-syntax-cases.json entstehen im privaten Fixture-Verzeichnis. Der Feature-Matrix liegen zusaetzlich manuelle Quelltextpruefungen zugrunde; sie wird nicht automatisch aus diesen beiden Werkzeugen erzeugt.
