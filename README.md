# Nomen est

Flutter-Web-PWA für den Unterricht: Namen lernen, jemanden aufrufen, Gruppen
bilden. Konzept und Designentscheide stehen in
[KONZEPT-nomen-est.md](KONZEPT-nomen-est.md) und
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md), die
Arbeitsweise und die Fallen in [CLAUDE.md](CLAUDE.md).

**Live: https://masta-nksa.github.io/nomen-est/**

Aus einem Klassenfoto-PDF wird eine Klasse: die App findet Fotos und Namen
selbst. Darauf bauen vier Werkzeuge auf.

| | |
|---|---|
| **Namen lernen** | Foto→Name und Name→Foto, Leitner-Boxen, Verwechslungsmatrix. Der Umfang wächst automatisch mit: erst eine Handvoll, dann kommt dazu, wer nachrückt |
| **Zufall** | Jemanden aufrufen, mit oder ohne Wiederholung. Der Topf wird aus dem Ziehungs-Log berechnet und überlebt Sitzungen |
| **Gruppen** | Nach Anzahl, Grösse oder Bereich, gleichmässig oder nicht |
| **Anwesenheit** | Einmal pro Lektion gesetzt, gilt für Ziehung und Gruppen |

Ziehung und Gruppen haben einen Beamermodus: keine Bedienleiste, grosse
Fotos, Bedienung blendet sich nach drei Sekunden aus.

Wer häufiger verwechselt wird, kommt öfter dran — und wird bevorzugt gegen
genau die Person gestellt, mit der man sie verwechselt.

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
flutter build web --base-href /nomen-est/
```

Die PDFium-Assets bringt `pdfrx` selbst mit — die landen automatisch im Build.

## Deployment

Ein Push auf `master` baut und veröffentlicht die App über GitHub Actions auf
GitHub Pages (siehe [.github/workflows/deploy.yml](.github/workflows/deploy.yml)).

Derselbe Workflow baut zusätzlich den Branch `preview` nach
`/nomen-est/preview/` — gedacht, um einen Stand auf dem iPad oder am
Beamer zu prüfen, bevor er auf `master` landet:

```bash
git push --force origin HEAD:preview
```

Beide URLs teilen sich denselben Origin und damit **dieselbe Browser-Datenbank**.
Das ist Absicht (so testet die Preview auf echten Klassen), heisst aber: eine
Schemaänderung in der Preview wirkt auch für die Live-App.

Nach einem Deploy meldet die App eine neue Fassung über ein Banner. Beim Testen
hilft ein harter Reload (Strg+Shift+R).
