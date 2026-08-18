# Nomen est — Arbeitsweise

Flutter-Web-PWA, produktiv unter https://masta-nksa.github.io/nomen-est/.
Konzept und Begründungen stehen in [KONZEPT-nomen-est.md](KONZEPT-nomen-est.md)
und [KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md); dort steht
auch, wo die Umsetzung bewusst vom Entwurf abweicht und warum. **Wer etwas
ändert, zieht diese Dokumente mit** — sie sind der Grund, warum eine
Entscheidung später noch nachvollziehbar ist.

## Sprache

Oberfläche und Konzeptdokumente auf Deutsch, Code und Kommentare auf Englisch.
Kommentare erklären das *Warum*, nicht das *Was*.

## Ablauf einer Änderung

```bash
flutter analyze
flutter test
```

Beides muss grün sein, bevor committet wird. Danach:

```bash
git push origin master
git push --force origin master:preview
```

Der zweite Push hält die Preview auf demselben Stand. `master` landet unter
`/nomen-est/`, der Branch `preview` unter `/nomen-est/preview/` —
derselbe Workflow baut beide.

## Fallen, die schon Zeit gekostet haben

**Nur ein Testlauf gleichzeitig.** Zwei parallele `flutter test` streiten um
`build/native_assets/windows/sqlite3.dll`; der zweite bleibt beim „loading"
stehen. Hängt ein Lauf, zuerst nach verwaisten `flutter_tester`-Prozessen
suchen, nicht nach der Ursache im Test.

**Drift-Streams und `pumpAndSettle` vertragen sich nicht.** Eine laufende
`watch()`-Abfrage plant Timer ein, die Testuhr feuert sie, das Feuern erzeugt
neue — `pumpAndSettle` kommt nie zurück. In Widget-Tests die Streams als
fertigen Wert übergeben (`studentsProvider.overrideWith((ref, id) =>
Stream.value(...))`). Auf dem Gerät gibt es das Problem nicht.

**Widget-Tests laufen als Android** und mit 800×600 im Querformat. Alles, was
`defaultTargetPlatform` oder die Fenstergrösse abfragt, nimmt dort stillschweigend
den Touch-Pfad. Fenstergrösse im Test setzen, wenn es darauf ankommt.

**Eine `ListView` baut nur, was sichtbar ist.** Assertions auf Elemente weiter
unten scheitern, obwohl der Code stimmt — Testfenster hoch genug machen.

**Eine Datenbank-Transaktion im Testkörper braucht `tester.runAsync`.** In der
Fake-Async-Zone wird sie sonst nie fertig und der Test hängt.

**Migrationen müssen wiederholbar sein.** Drift führt sie ohne Transaktion aus
und schreibt die Versionsnummer erst danach; ein abgebrochener Schritt lässt die
vorherigen stehen. Schritte deshalb an den *tatsächlichen* Schemazustand knüpfen
(`sqlite_master`, `pragma_table_info`), nicht an die Versionsnummer. Und drift
generiert `CREATE INDEX` ohne `IF NOT EXISTS` — Indizes als explizites SQL.

**Kein Mass aus einem Extremum über alle Elemente ableiten.** Ein einzelnes
verrutschtes Foto hat schon einmal die gemessene Spaltenbreite und damit alle
Vornamen einer Klasse gekostet, ein zu hohes Foto die Zeilenhöhe.

**Quelldateien nicht über PowerShell-Pipelines umschreiben.** `Get-Content` ohne
`-Encoding utf8` liest UTF-8 als ANSI und macht aus „Würfeln" „WÃ¼rfeln".

## Daten von Jugendlichen

Klassenfoto-PDFs und exportierte ZIPs gehören **nie** ins Repo; `.gitignore`
blockt `*.pdf`, `*.zip` und `/pdfs/`. Vor jedem `git add -A` lohnt der Blick auf
`git status`. Lokal liegen in `pdfs/` echte Klassen als Testvorlagen — die
Parser-Tests überspringen sich selbst, wenn sie fehlen, weshalb CI ohne sie
durchläuft.
