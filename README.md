# Nomen est

Flutter-Web-PWA zum Lernen von Schüler:innen-Namen anhand der Klassenfoto-PDFs
der Schulverwaltung. Konzept und Designentscheide stehen in
[KONZEPT-namen-lern-app.md](KONZEPT-namen-lern-app.md).

## Datenschutz

Es sind Fotos von Jugendlichen. Deshalb:

- Alle Daten bleiben auf dem Gerät — kein Backend, keine Cloud, kein Analytics
- Nach dem Laden der App gibt es keinen ausgehenden HTTP-Request mehr
  (per Flugmodus überprüfbar)
- **Klassenfoto-PDFs und exportierte ZIPs gehören nie ins Repo.** `.gitignore`
  blockt `*.pdf`, `*.zip` und `/pdfs/`.

Auf iPhone/iPad die App zuerst zum Home-Bildschirm hinzufügen und *danach*
importieren: Safari löscht bei normalen Websites nach 7 Tagen ohne Interaktion
den Speicher, installierte PWAs sind davon ausgenommen.

## Entwicklung

```bash
flutter pub get
dart run build_runner build        # Drift-Code generieren
flutter test
```

Die Tests für den PDF-Parser laufen gegen die echten Klassen-PDFs in `pdfs/`.
Sind die nicht vorhanden, überspringen sie sich selbst.

### Web

Der Web-Build braucht die WebAssembly-Dateien von drift, die nicht im Repo
liegen:

```bash
bash tool/fetch_web_assets.sh
flutter build web --base-href /namen-lern-app/
```

Die PDFium-Assets bringt `pdfrx` selbst mit — die landen automatisch im Build.

## Deployment

Ein Push auf `master` baut und veröffentlicht die App über GitHub Actions auf
GitHub Pages (siehe [.github/workflows/deploy.yml](.github/workflows/deploy.yml)).
