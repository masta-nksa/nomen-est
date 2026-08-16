# Nomen est

Flutter-Web-PWA zum Lernen von Schüler:innen-Namen anhand der Klassenfoto-PDFs
der Schulverwaltung. Konzept und Designentscheide stehen in
[KONZEPT-namen-lern-app.md](KONZEPT-namen-lern-app.md), das geplante Kapitel zu
Zufallsgenerator und Gruppeneinteilung in
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md).

**Live: https://masta-nksa.github.io/namen-lern-app/**

Aus einem Klassenfoto-PDF wird ein Klassensatz: die App findet Fotos und
Namen selbst, danach übt man sie in Quiz-Modi. Wer häufiger verwechselt
wird, kommt öfter dran — und wird bevorzugt gegen genau die Person
gestellt, mit der man sie verwechselt.

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
Sind die nicht vorhanden, überspringen sie sich selbst — deshalb läuft
`flutter test` auch in CI durch, wo die PDFs bewusst fehlen.

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
