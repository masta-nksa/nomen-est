# Namen-Lern-App — Projektkonzept

Flutter-App zum Lernen von Schüler:innen-Namen anhand der Klassenfoto-PDFs
der Schulverwaltung. Primäres Deployment: Flutter Web als PWA auf GitHub
Pages, zusätzlich optional native Builds.

---

## 1. Ziel

Aus einem PDF mit Passfotos + Namen wird ein "Klassensatz". Der Satz kann
in verschiedenen Quiz-Modi geübt werden. Personen, die man häufiger falsch
zuordnet, kommen häufiger dran.

Mehrere Klassensätze werden parallel verwaltet. Beim App-Start:
üben (Satz auswählen) oder neuen Satz per PDF anlegen.

---

## 2. Technologie-Stack

```yaml
dependencies:
  pdfrx: ^2.x           # PDF-Rendering + Textkoordinaten (PDFium), alle Plattformen
  image: ^4.x           # Schwellwert, Projektionsprofil, Cropping, JPEG-Encoding
  drift: ^2.x           # SQLite: nativ + sqlite3 WASM auf Web
  file_picker: ^8.x     # PDF auswählen
  flutter_riverpod: ^2.x  # optional; bei ~6 Screens tut es auch Provider
  archive: ^3.x         # ZIP-Export/-Import von Klassensätzen
```

**Warum Drift und nicht Isar:** Isar v3 ist faktisch im Wartungsmodus,
v4 hängt. Drift wird aktiv gepflegt und deckt Web sauber ab — bei
gemischter Gerätenutzung (iOS/Android/Laptop) ist das entscheidend.

**Fotos als BLOB in die Datenbank**, nicht ins Dateisystem. Bei ~30
Personen à ~6 KB sind das ~200 KB pro Satz. Erspart die komplette
Web-vs-Native-Fallunterscheidung beim Dateizugriff.

**Achtung Web-Build:** pdfrx braucht auf Web die PDFium-WASM-Assets.
Die müssen gemäss pdfrx-Doku im Build mitgeliefert werden — beim ersten
Deploy dafür Zeit einplanen.

---

## 3. PDF-Import — der Kern

### 3.1 Format der Quell-PDFs

Erzeugt von TCPDF, A4 (595.276 × 841.89 pt), mit echter Textebene
(kein OCR nötig).

- Fotos als eingebettete JPEGs, 200×200 px, ~5–7 KB, in Lesereihenfolge
- Raster: Spalten bei x = 42.9 / 142.2 / 241.6 / 341.0 / 440.4 pt
  (Abstand 99.35 pt), Zeilen im Abstand 136.2 pt
- Foto: 76.5 × 76.5 pt
- Name beginnt exakt auf derselben x-Position wie das Foto darüber
- Erste Namenszeile liegt 31.4 pt unter der Fotounterkante
- Lange Namen brechen auf zwei Zeilen um (Zeilenabstand ~8.6 pt)
- Letzte Seite kann beliebig wenige Fotos enthalten (auch nur eines)

Diese Konstanten dienen als Referenz/Plausibilisierung. Der Algorithmus
unten ist bewusst so gebaut, dass er sie **nicht** hart voraussetzt —
falls die Schulverwaltung das Template ändert, läuft er weiter.

### 3.2 Fotoerkennung über Projektionsprofil

In Dart gibt es keinen zuverlässigen Zugriff auf eingebettete
Bild-Objekte. Deshalb: Seite rendern und die Fotorechtecke im Bitmap
finden. Verfahren gegen die Beispiel-PDFs verifiziert.

```
1. Seite bei 200 DPI rendern (pdfrx) → RGBA-Bitmap
   76.5 pt → 213 px, also praktisch Originalauflösung der eingebetteten JPEGs

2. In Graustufen wandeln; Pixel gilt als "Tinte" wenn Wert < 245

3. ZEILENPROJEKTION (Summe Tinte-Pixel pro Bildzeile):
     Band beginnt, wenn Summe > 4 % der Seitenbreite
     Band nur behalten, wenn Höhe > 80 px
   → Der Höhenfilter ist der Trick: Textzeilen sind ~20 px hoch,
     Fotos 213 px. Damit fallen alle Textzeilen automatisch raus,
     und die Schwelle darf niedrig genug sein, dass auch eine
     Zeile mit nur einem einzigen Foto erkannt wird.

4. SPALTENPROJEKTION innerhalb jedes Bands:
     Box beginnt, wenn Summe > 50 % der Bandhöhe
     Box nur behalten, wenn Breite > 80 px
   → ergibt die einzelnen Fotorechtecke

5. Crop je Box → als JPEG (Qualität ~85) encodieren
```

Verifizierte Ergebnisse: 21 / 25 / 1 Fotos auf den drei Testseiten,
jeweils korrekt.

### 3.3 Namenszuordnung

```
1. Textfragmente mit Koordinaten holen (pdfrx Text-API)

2. Kopfzeile ausschliessen: alles oberhalb des obersten Fotobands

3. Pro Fotobox: Wörter sammeln, für die gilt
     box.x0 - 3 <= wort.x0 < box.x0 + spaltenbreite - 3
     box.unterkante < wort.top < box.unterkante + 70

4. Gesammelte Wörter nach (top, x0) sortieren und zu Zeilen gruppieren
   (gleiches top ± 2)

5. Zeilen nur solange anhängen, wie der Abstand zur vorherigen Zeile
   < 14 pt ist
   → killt das Fusszeilen-Datum, das sonst beim letzten Foto der
     ersten Spalte mit eingesammelt wird ("Wernli Carina 11. August 2026")

6. Wörter mit Leerzeichen verbinden → displayName
```

Verifiziert: alle Namen beider Test-PDFs korrekt, inklusive zweizeiliger
Namen und der Folgeseite mit einem einzelnen Foto.

### 3.4 Vor-/Nachnamen-Trennung

Im PDF steht "Nachname Vorname(n)", aber die Grenze ist **nicht**
zuverlässig ableitbar:

- `Brändli Lyan` → Nachname 1 Token
- `Huber Diana Elena` → Nachname 1 Token, zwei Vornamen
- `Ahumada Torres Gloria` → Nachname **2** Tokens
- `Mühlhäuser Niklas David` → Nachname 1 Token, zwei Vornamen

**Heuristik:** erstes Token = Nachname, Rest = Vornamen.
**Dazu zwingend ein Review-Screen** nach dem Import, auf dem die
Trennstelle pro Person antippbar/verschiebbar ist. Kostet ~30 s pro
Klasse und macht den Modus "nur Vorname" überhaupt erst möglich.

---

## 4. Datenmodell (Drift)

```dart
PhotoSets
  id            int, pk
  label         text        // z.B. "INF-G1H-SMA"
  sourceFile    text        // Original-Dateiname, nur zur Anzeige
  importedAt    datetime

Persons
  id            int, pk
  setId         int, fk -> PhotoSets
  displayName   text        // "Ahumada Torres Gloria"
  firstName     text        // nach Review korrigierbar
  lastName      text
  jpegBytes     blob
  orderIndex    int

Progress
  personId      int, pk, fk -> Persons
  box           int         // 1..5, Leitner
  correct       int
  wrong         int
  streak        int
  lastSeenAt    datetime
  avgMs         int

Confusions
  personId        int, fk -> Persons   // gezeigte Person
  confusedWithId  int, fk -> Persons   // fälschlich gewählte Person
  count           int
  pk (personId, confusedWithId)
```

---

## 5. Lernlogik

### 5.1 Leitner-Boxen

- Richtig beantwortet → `box = min(5, box + 1)`
- Falsch beantwortet → `box = max(1, box - 2)`

### 5.2 Auswahl der nächsten Person

```
gewicht = (6 - box)^2 + 2 * kürzliche_Fehler + kleines Zufallsrauschen
```

Zusätzlich ein Cooldown: dieselbe Person nicht zweimal direkt
hintereinander, und innerhalb einer Session möglichst erst alle
einmal zeigen, bevor wiederholt wird.

### 5.3 Verwechslungsmatrix — das eigentliche Feature

Wird bei Foto A fälschlich Name B gewählt, dann `Confusions[A][B]++`.

Beim nächsten Auftreten von A werden bevorzugt genau die Personen mit
hohem `count` als Distraktoren angeboten. Damit wird gezielt die
Unterscheidung trainiert, die schwerfällt — statt zufälliger Ablenker,
die man ohnehin sofort ausschliessen kann.

Das ist der Unterschied zu einer gewöhnlichen Karteikarten-App und
sollte nicht wegoptimiert werden.

---

## 6. Lernmodi und Schwierigkeitsstufen

### Modi

| # | Modus | Beschreibung | Priorität |
|---|-------|--------------|-----------|
| 1 | Foto → Name | Foto zeigen, n Namen zur Auswahl | MVP |
| 2 | Name → Foto | Name zeigen, n Fotos zur Auswahl | MVP |
| 3 | Galerie | Alle Fotos + Namen zum Anschauen, kein Quiz | MVP |
| 4 | Foto → tippen | Namen eintippen, Levenshtein-Toleranz ≤ 2 | später |
| 5 | Speed-Runde | Modus 1 mit hartem Zeitlimit | später |
| 6 | Zuordnungsraster | Alle Fotos per Drag & Drop den Namen zuordnen | später |
| 7 | Fokus-Runde | Nur Personen mit Box ≤ 2 oder hohem Confusion-Count | später |
| 8 | Verwechslungs-Vergleich | Die zwei meistverwechselten Fotos direkt nebeneinander | später |
| 9 | Freies Nennen | Foto zeigen, Name selbst denken, dann per Antippen aufdecken | später |

Modi 7–9 brauchen **keine** Änderung am Datenmodell — `Progress.box`
und `Confusions.count` (Abschnitt 4) reichen bereits aus. Damit ist
die Architektur für sie vorbereitet, auch wenn die Umsetzung erst
in einer späteren Version erfolgt.

Ebenfalls zurückgestellt, aber mitzudenken: ein **Tagesziel /
Session-Länge**-Regler (z. B. "15 Karten" statt "eine Runde bis
Abbruch"). Das ist reiner UI-/Session-State, braucht keine
Datenmodell-Änderung — kann jederzeit nachgerüstet werden.

### Stufen als drei unabhängige Regler

| Regler | Werte |
|--------|-------|
| Anzahl Optionen | 3 / 5 / 8 |
| Distraktor-Auswahl | zufällig → gleicher Anfangsbuchstabe → aus Verwechslungsmatrix |
| Zeitlimit | keins / 8 s / 4 s |

Zusätzlich umschaltbar: nur Vorname / nur Nachname / beides.

Die Regler frei kombinierbar lassen und drei Presets anbieten
(Leicht / Mittel / Schwer), die sie setzen.

---

## 7. Screens

```
Start
 ├── "Üben" → Satz auswählen → Modus + Stufe → Quiz → Auswertung
 ├── "Neuer Satz" → PDF wählen → Klassenname vergeben → Import läuft
 │                → Review-Screen → speichern
 └── "Sätze verwalten"
      ├── Satz umbenennen
      ├── Statistik pro Satz anzeigen             [V1, Prio mittel]
      ├── Satz als ZIP exportieren
      ├── ZIP importieren
      ├── Satz löschen (Bestätigungsdialog, danach Undo-Snackbar ~5 s)
      ├── Fortschritt zurücksetzen                [V2, Prio tief]
      └── Sortieren / Suchen in der Sätze-Liste    [V2, Prio tief]
```

**Foto-Zoom (V1, Prio hoch):** überall wo ein Foto als Thumbnail
erscheint — Review-Screen-Raster, Galerie, Quiz — öffnet Antippen
eine vergrösserte Ansicht (Dialog/Lightbox, per Tap/Escape wieder zu).
Technisch nur ein Hochskalieren des gespeicherten Bilds, keine
höhere Auflösung verfügbar: Quelle ist das PDF-Rendering bei 200 DPI
(→ 213×213 px, Abschnitt 3.2), als JPEG-Blob in `Persons.jpegBytes`
abgelegt. Für Gesichtserkennung auf Miniaturgrösse reicht das trotzdem
deutlich besser als die Ausgangsgrösse im Raster.

**Statistik pro Satz (V1, Prio mittel):** in "Sätze verwalten" bzw.
auf der Satz-Auswahl direkt sichtbar, z. B. "18/25 sicher" (Personen
mit `box >= 4`). Reine Aggregation über die bestehende `Progress`-
Tabelle, keine neue Persistenz nötig. Da "mittel" Priorität hat: als
erstes kandidatenfähig zu kürzen, falls V1 zeitlich eng wird.

**Fortschritt zurücksetzen (V2, Prio tief):** setzt für einen Satz
alle `Progress`-Zeilen auf `box=1, correct=0, wrong=0, streak=0` und
löscht die zugehörigen `Confusions` — ohne den Satz selbst (Fotos/
Namen) neu importieren zu müssen. Festgehalten für später, keine
Architektur-Vorbereitung nötig, da es nur bestehende Tabellen leert.

**Sortieren/Suchen (V2, Prio tief):** Sätze-Liste nach zuletzt
geübt / alphabetisch sortierbar, plus Suchfeld ab einer gewissen
Anzahl Sätze. Rein UI-seitig, keine Datenmodell-Änderung.

**Klassenname (`PhotoSets.label`):** wird direkt nach der PDF-Auswahl
abgefragt, bevor der Import läuft (Vorschlag: Dateiname ohne Endung als
Default, frei überschreibbar). Im Review-Screen und über "Satz
umbenennen" jederzeit änderbar. Pflichtfeld — ohne Namen keine
Sätze-Liste, die auf einen Blick unterscheidbar ist.

**Satz löschen** entfernt den PhotoSet inklusive aller `Persons`
(kaskadierend, wegen der BLOB-Fotos) und der zugehörigen `Progress`-
und `Confusions`-Einträge. Löschen ist wegen der Fotos irreversibel
gemeint — deshalb Bestätigungsdialog mit Klassennamen zum Abtippen
oder zumindest Ja/Nein, plus kurze Undo-Snackbar, bevor tatsächlich
aus der DB gelöscht wird.

Der **Review-Screen** nach dem Import zeigt alle erkannten Karten als
Raster: Foto + erkannter Name + antippbare Vor-/Nachnamen-Trennstelle.
Karten können gelöscht und Namen manuell korrigiert werden.

Die **Auswertung** nach einer Runde zeigt: Trefferquote, die Personen
mit den meisten Fehlern, und die häufigsten Verwechslungspaare
("Du verwechselst X und Y regelmässig").

---

## 8. Datenhaltung und Persistenz

- Drift auf Web = SQLite (WASM) über OPFS bzw. IndexedDB, gebunden an
  den Origin. Überlebt Tab schliessen, Browser-Neustart, Geräteneustart.
- Flutter Web erzeugt automatisch einen Service Worker → App läuft nach
  dem ersten Aufruf offline.
- **Einmal pro Gerät importieren, dann ist der Satz dauerhaft da.**

### Fallstricke

**iOS:** Safari löscht bei Websites nach 7 Tagen ohne Interaktion allen
skriptbeschreibbaren Speicher (IndexedDB, LocalStorage, Service Worker).
Zum Home-Bildschirm hinzugefügte Web-Apps sind ausgenommen.

→ Auf iPhone/iPad **zuerst "Zum Home-Bildschirm hinzufügen", dann erst
importieren.** Eine installierte PWA hat einen eigenen Speicher-Container;
Daten aus dem normalen Safari wandern nicht mit.

→ In der App beim ersten Start einen kurzen Hinweis dazu einblenden.

**`navigator.storage.persist()`** beim ersten Import (und bei jedem
App-Start) anfordern. Schützt in Chrome/Edge/Firefox gegen Eviction bei
Speicherknappheit; für Safari nicht offiziell dokumentiert, hilft in der
Praxis aber offenbar auch.

**"Website-Daten löschen" löscht die Klassensätze.** Deshalb ist der
ZIP-Export Pflicht, nicht optional.

**Sätze sind pro Gerät.** Ein Import auf dem Laptop ist auf dem Handy
nicht vorhanden. Lösungen: ZIP-Export/-Import, oder das PDF einfach
erneut importieren (dauert Sekunden, aber die Lernfortschritte fehlen
dann).

---

## 9. Datenschutz

Es sind Fotos von Jugendlichen. Deshalb:

- Keine Cloud, kein Backend, kein Analytics, keine externen Fonts oder CDNs
- Kein einziger ausgehender HTTP-Request nach dem Laden der App —
  im Code bewusst so halten, dass das per Flugmodus-Test überprüfbar bleibt
- Pro Klassensatz ein "vollständig löschen"-Knopf
- Beim Start des neuen Schuljahrs alte Sätze löschen
- **Die PDFs und exportierten ZIPs niemals ins GitHub-Repo committen.**
  Entsprechende Einträge in `.gitignore` (`*.pdf`, `*.zip`, `/testdata/`)
  gleich zu Beginn anlegen.

Falls die Test-PDFs für Unit-Tests im Repo liegen müssten: das Repo
privat halten oder die Tests gegen anonymisierte Dummy-PDFs laufen lassen.

---

## 10. Deployment

- Flutter Web Build → GitHub Pages
- `--base-href` auf den Repo-Pfad setzen
- PDFium-WASM-Assets mitliefern (pdfrx-Doku)
- HTTPS ist über GitHub Pages gegeben und für Service Worker und
  Storage-APIs Voraussetzung
- Optional zusätzlich nativer Android-Build; iOS nativ lohnt sich
  wegen des Apple-Developer-Accounts nicht, dafür ist die PWA da

---

## 11. Umsetzungsreihenfolge

Schritt 1 enthält das einzige echte technische Risiko. Erst weiter,
wenn er grün ist.

1. **`lib/import/pdf_import.dart` isoliert bauen**
   Reine Dart-Funktion `Future<List<ImportedPerson>> parsePdf(Uint8List bytes)`.
   Dazu Unit-Tests gegen die beiden Beispiel-PDFs.
2. Drift-Schema + Import-Screen mit Klassenname-Abfrage + Review
3. Foto-Zoom im Review-Screen (Lightbox-Widget einmal bauen,
   in Galerie/Quiz wiederverwenden)
4. Modus 1 (Foto → Name), Auswahllogik zunächst rein zufällig
5. Leitner-Boxen + Verwechslungsmatrix nachrüsten
6. Modus 2 + Galerie
7. Statistik pro Satz (Aggregation über `Progress`)
8. Stufenregler und Presets
9. ZIP-Export/-Import
10. Web-Build + GitHub Pages + PWA-Manifest
11. Modi 4–6

**V2-Backlog** (bewusst zurückgestellt, keine Architektur-Blocker):
Fortschritt zurücksetzen, Sortieren/Suchen in der Sätze-Liste,
Modi 7–9 (Fokus-Runde, Verwechslungs-Vergleich, Freies Nennen),
Tagesziel-Regler.

---

## 12. Testfälle für den Parser

Erwartete Ergebnisse aus den beiden Referenz-PDFs:

| PDF | Seiten | erwartete Personen |
|-----|--------|--------------------|
| Gymi-Satz (INF-G1H-SMA) | 1 | 21 |
| FMS-Satz (INF-F1a-SMA) | 2 | 25 + 1 = 26 |

Diese Fälle müssen explizit abgedeckt sein:

- **Seite mit einem einzigen Foto** (letzte Seite FMS-Satz) — hier
  scheitert eine zu hohe Schwelle im Zeilenprojektionsprofil
- **Zweizeilige Namen** — z.B. "Goldenberger / Larissa",
  "Mühlhäuser Niklas / David"
- **Fusszeilen-Datum** darf nicht an den letzten Namen der ersten
  Spalte angehängt werden
- **Kopfzeile** ("Fotos des Kurses ...") darf keine Karte erzeugen
- **Zweiteiliger Nachname** ("Ahumada Torres Gloria") — Heuristik darf
  hier falsch liegen, aber die Korrektur im Review muss greifen
- **Nicht volle letzte Zeile** (Gymi-Satz: 4 volle Zeilen + 1 Foto)

Sinnvoll: einen Debug-Screen, der nach dem Parsen die erkannten
Bounding-Boxen als Overlay über die gerenderte Seite legt. Spart bei
Problemen viel Rätselraten.
