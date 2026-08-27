# Nomen est — Arbeitsweise

Flutter-Web-PWA, produktiv unter https://masta-nksa.github.io/nomen-est/.
Konzept und Begründungen stehen in [KONZEPT-nomen-est.md](KONZEPT-nomen-est.md)
und [KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md), die
geplanten Features in [KONZEPT-adaptives-lernen.md](KONZEPT-adaptives-lernen.md)
und [KONZEPT-fotos-und-klassenpflege.md](KONZEPT-fotos-und-klassenpflege.md);
dort steht auch, wo die Umsetzung bewusst vom Entwurf abweicht und warum. **Wer etwas
ändert, zieht diese Dokumente mit** — sie sind der Grund, warum eine
Entscheidung später noch nachvollziehbar ist.

## Sprache

Oberfläche und Konzeptdokumente auf Deutsch, Code und Kommentare auf Englisch.
Kommentare erklären das *Warum*, nicht das *Was*.

## Ablauf einer Änderung

**Nichts geht direkt auf `master`.** Die App ist freigegeben und wird im
Unterricht benutzt; ein Push auf `master` steht binnen Minuten auf den Geräten
der Klassen. Jede Änderung entsteht deshalb in einem eigenen Branch und wird
unter `/nomen-est/preview/` angesehen. Auf `master` kommt sie erst, wenn das
ausdrücklich verlangt wird — nicht, weil sie fertig aussieht, und auch nicht,
weil die Tests grün sind.

```bash
git switch -c thema/kurzer-name
```

Am Ende der Arbeit:

```bash
flutter analyze
flutter test
```

Beides muss grün sein, bevor committet wird. Danach den Branch sichern und zur
Ansicht stellen:

```bash
git push -u origin thema/kurzer-name
git push --force origin thema/kurzer-name:preview
```

Erst der zweite Push veröffentlicht etwas: der Workflow läuft nur für `master`
und `preview`, ein Push auf den Themenbranch allein baut nichts. `preview` ist
eine Anzeigefläche, kein Sammelbecken — der nächste Branch überschreibt sie,
und das ist beabsichtigt.

`master` landet unter `/nomen-est/`, `preview` unter `/nomen-est/preview/` —
derselbe Workflow baut beide.

### Nach `master` — nur auf ausdrückliche Freigabe

```bash
git switch master
git merge --no-ff thema/kurzer-name
git push origin master
```

Bis diese Freigabe vorliegt, bleibt der Branch stehen. Im Zweifel nachfragen
statt mergen.

## Fallen, die schon Zeit gekostet haben

**Die Flutter-Version ist im Workflow festgenagelt** (`flutter-version: 3.47.1`
in [.github/workflows/deploy.yml](.github/workflows/deploy.yml)). Wer lokal eine
andere Version fährt, testet nicht das, was ausgeliefert wird — `flutter test`
grün heisst dann nicht, dass CI grün wird. Vor dem Arbeiten `flutter --version`
vergleichen.

Der Grund für die Bindung: Flutter bestimmt `main.dart.js`, `flutter.js` und
das ganze `canvaskit/`-Verzeichnis. Auf `channel: stable` allein brachte der
nächste beliebige Commit den Klassen eine neue Engine, ohne dass jemand ein
Update beschlossen hätte. Ein Versionswechsel ist deshalb eine eigene
Änderung — und dabei ist `web/flutter_bootstrap.js` gegen Flutters Vorlage in
`packages/flutter_tools/lib/src/web/bootstrap.dart` zu prüfen, weil die Datei
eine Kopie davon ist.

**Service Worker und Bootstrap gehören zusammen.** `web/sw.js` ist selbst
gebaut — Flutter liefert seit 3.44 keinen mehr, der etwas cached, und
registriert für neue Besucher auch keinen. `web/flutter_bootstrap.js` ist eine
Kopie von Flutters Vorlage ohne `serviceWorkerSettings`; sie hält den Loader
davon ab, den eigenen Worker durch seinen Aufräumer zu ersetzen. Wer eine der
beiden Dateien anfasst, muss die andere mitdenken. Der Platzhalter
`__BUILD_ID__` in `sw.js` muss stehen bleiben: der Deploy ersetzt ihn durch
einen Hash der gebauten Dateien und bricht ab, wenn er fehlt. Hintergrund in
[KONZEPT-nomen-est.md](KONZEPT-nomen-est.md), Abschnitt 8.

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
