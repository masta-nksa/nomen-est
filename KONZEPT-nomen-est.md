# Nomen est — Projektkonzept

Flutter-App für den Unterricht, aufgebaut auf den Klassenfoto-PDFs der
Schulverwaltung: Namen lernen, jemanden aufrufen, Gruppen bilden. Primäres
Deployment: Flutter Web als PWA auf GitHub Pages, zusätzlich optional native
Builds.

Dieses Dokument deckt den Import, das Datenmodell und den Lernmodus ab;
Zufallsgenerator und Gruppeneinteilung stehen in
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md).

> **Stand:** Lernmodus, Zufallsgenerator, Gruppeneinteilung, Anwesenheit und
> Beamermodus gebaut und live unter
> https://masta-nksa.github.io/nomen-est/ — siehe Abschnitt 11.
> Dieses Dokument beschreibt sowohl die Entscheide als auch den
> umgesetzten Stand; abweichende Stellen sind als solche markiert.

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

**Achtung Web-Build — beide Pakete brauchen eine Extrawurst.** Das kostet
beim ersten Deploy Zeit und fällt in Tests *nicht* auf, weil die weder
über `main()` laufen noch den Web-Codepfad nehmen:

- **pdfrx** richtet seine PDFium-WASM-Einstiegspunkte erst in
  `pdfrxFlutterInitialize()` ein. Wer die Dokument-API nutzt, ohne je ein
  pdfrx-Widget zu bauen, muss das selbst aufrufen — sonst
  `UnimplementedError: PdfrxEntryFunctions.instance is not initialized`.
  Der Aufruf steht deshalb in `parsePdf()` selbst (er ist idempotent), damit
  Aufrufer nichts wissen müssen. Die PDFium-Assets selbst liefert pdfrx mit,
  die landen automatisch im Build.
- **drift** braucht auf Web explizite `DriftWebOptions` mit den URIs zu
  `sqlite3.wasm` und `drift_worker.js` — ohne die wirft schon das Öffnen der
  Datenbank („When compiling to the web, the `web` parameter needs to be
  set"). Diese zwei Dateien liegen **nicht** im Repo, sondern holt
  `tool/fetch_web_assets.sh` aus dem passenden drift-Release.

In Unit-Tests muss `Pdfrx.cacheDirectoryPath` vorab gesetzt werden, sonst
fragt die Initialisierung über path_provider nach einem Cache-Verzeichnis
und scheitert am fehlenden Plattform-Channel.

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

3. Spaltenkanten bestimmen: alle box.x0 sortieren und alle, die weniger
   als eine halbe Fotobreite auseinanderliegen, zu einer Spalte
   zusammenfassen (linkeste zählt). Spaltenbreite = kleinster Abstand
   zwischen zwei Spalten.
   → Ohne diesen Schritt genügt ein einziges Foto, das ein paar Pixel
     neben seiner Spalte sitzt, um die gemessene Spaltenbreite auf diese
     paar Pixel zu drücken — und dann bekommt jede Person auf der Seite
     nur noch ihr erstes Wort.

4. Pro Fotobox: Wörter sammeln, für die gilt
     spalte.x0 - 3 <= wort.x0 < spalte.x0 + spaltenbreite - 3
     zeilen.unterkante < wort.top < zeilen.unterkante + 70
   → gesucht wird ab der Spalten- und der Zeilenkante, nicht ab der
     Fotokante: ein schmaleres oder tiefer sitzendes Foto findet seinen
     Namen sonst nicht, weil sein Fenster rechts oder über dem Text liegt.

5. Gesammelte Wörter nach (top, x0) sortieren und zu Zeilen gruppieren
   (gleiches top ± 2)

6. Zeilen behalten, solange drei Bedingungen gelten: Abstand zur
   Vorzeile < 14 pt, höchstens zwei Zeilen, und keine Ziffer in der
   Zeile (`nameLineCount`)
   → killt das Fusszeilen-Datum. Der Abstand allein genügt nicht: bei
     einem umbrechenden Namen liegt das Datum nur 11 pt unter der
     zweiten Zeile. Namen tragen keine Ziffern, Daten schon.

7. Wörter mit Leerzeichen verbinden → displayName
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
Classes                     // Datenklasse: SchoolClass
  id            int, pk
  label         text        // z.B. "INF-G1H-SMA"
  sourceFile    text        // Original-Dateiname, nur zur Anzeige
  importedAt    datetime

Students
  id            int, pk
  classId       int, fk -> Classes
  displayName   text        // "Ahumada Torres Gloria"
  firstName     text        // nach Review korrigierbar
  lastName      text
  jpegBytes     blob
  orderIndex    int
  active        bool        // Klassenwechsel: deaktivieren statt löschen

Progress
  studentId     int, pk, fk -> Students
  box           int         // 1..5, Leitner
  correct       int
  wrong         int
  streak        int
  lastSeenAt    datetime
  avgMs         int

Confusions
  studentId       int, fk -> Students   // gezeigte Person
  confusedWithId  int, fk -> Students   // fälschlich gewählte Person
  count           int
  pk (studentId, confusedWithId)
```

**Die Tabellen hiessen bis Schema-Version 1 `PhotoSets` und `Persons`.**
Umbenannt, als der Zufallsgenerator dazukam: Anwesenheit, Ziehungen und Gruppen
gehören zur Klasse, nicht zum PDF-Import, aus dem sie entstanden ist. Die
Migration benennt um und legt an, statt neu zu erstellen — vorhandene Fotos und
Lernfortschritte überleben sie, `test/migration_test.dart` prüft das gegen eine
von Hand aufgebaute v1-Datenbank.

Acht weitere Tabellen für Zufallsgenerator und Gruppen (`DrawEvents`,
`PoolResets`, `Absences`, `GroupSets`, `GroupMembers`, `PairCounts`,
`GroupConstraints`, `Settings`) sind in derselben Migration angelegt und in
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md) beschrieben.

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
hintereinander, und innerhalb einer Session erst alle einmal zeigen,
bevor wiederholt wird.

**Wichtig — das "erst alle einmal" gilt nur für den ersten Durchgang.**
Wird stur durchrotiert, bestimmt das Gewicht nur noch die Reihenfolge
innerhalb eines Zyklus, nicht mehr die Häufigkeit: jede Person käme
exakt gleich oft dran und die ganze Gewichtung wäre wirkungslos. Nach
dem ersten Durchgang wird deshalb aus allen Personen gewichtet gezogen.
(Genau dieser Fehler steckte in der ersten Implementierung.)

### 5.2b Antwortablauf

- **Richtig** → kurze grüne Bestätigung (~0,5 s), dann automatisch die
  nächste Karte bzw. die Auswertung. Kein Bestätigungsklick.
- **Erste falsche Antwort** → die gewählte Option wird rot markiert,
  die Lösung bleibt aber verdeckt, und es gibt **einen zweiten Versuch**.
  So muss man sich erinnern, statt die Lösung abzulesen.
- **Zweite falsche Antwort oder Zeitablauf** → die richtige Antwort wird
  gezeigt und bleibt stehen, bis man selbst weitergeht. Das ist der
  Moment, in dem man das Gesicht anschauen soll — hier wäre
  Auto-Weiterschalten kontraproduktiv.

**Gewertet wird nur der erste Versuch.** Ein Treffer im zweiten Anlauf
darf nicht wie Wissen aussehen, sonst wandern Personen in hohe
Leitner-Boxen, die man gar nicht sicher kann. Ein Zeitablauf zählt als
falsch und gibt keinen zweiten Versuch — das Zeitlimit *war* der
Versuch. Jede falsche Wahl (auch die zweite) zählt in die
Verwechslungsmatrix, das ist echte Information.

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

| # | Modus | Beschreibung | Stand |
|---|-------|--------------|-------|
| 1 | Foto → Name | Foto zeigen, n Namen zur Auswahl | **gebaut** |
| 2 | Name → Foto | Name zeigen, n Fotos zur Auswahl | **gebaut** |
| 3 | Galerie | Alle Fotos + Namen zum Anschauen, kein Quiz | **gebaut** |
| 4 | Foto → tippen | Namen eintippen, Levenshtein-Toleranz ≤ 2 | später |
| 5 | Speed-Runde | Modus 1 mit hartem Zeitlimit | teils (Zeitlimit-Regler da) |
| 6 | Zuordnungsraster | Alle Fotos per Drag & Drop den Namen zuordnen | später |
| 7 | Fokus-Runde | Nur Personen mit Box ≤ 2 oder hohem Confusion-Count | später |
| 8 | Verwechslungs-Vergleich | Die zwei meistverwechselten Fotos direkt nebeneinander | später |
| 9 | Freies Nennen | Foto zeigen, Name selbst denken, dann per Antippen aufdecken | später |

Modi 7–9 brauchen **keine** Änderung am Datenmodell — `Progress.box`
und `Confusions.count` (Abschnitt 4) reichen bereits aus. Damit ist
die Architektur für sie vorbereitet, auch wenn die Umsetzung erst
in einer späteren Version erfolgt.

Der **Session-Länge**-Regler ist gebaut: eine Runde umfasst
standardmässig 15 Karten (5–40 einstellbar), mit Fortschrittsbalken.

### Umfang — wie viel von der Klasse eine Runde abdeckt

Drei Antworten auf eine Frage, jede ein ganzer Satz statt eines Reglers:

| | |
|---|---|
| **Automatisch** (Standard) | Beginnt mit einer Handvoll und nimmt die nächste Person dazu, sobald eine sitzt |
| **Selbst einteilen** | Portionsgrösse (4/5/6/8) und Umfang (`1`, `1–2`, `1–3`, `alle`) von Hand |
| **Ganze Klasse** | Alle auf einmal |

Der Gewinn ist in allen Fällen die Wiederholrate: eine Runde von 15 Karten
zeigt bei 24 SuS jedes Gesicht etwa ein halbes Mal, bei einer Handvoll
dreimal.

**Die Regel des automatischen Modus:** Ab **Leitner-Box 3** — zweimal
richtig in Folge — gilt jemand als sitzend, und die nächste Person rückt
nach. Eine, nicht eine ganze Portion, damit die Runde knapp über dem
Können bleibt statt sprunghaft schwerer zu werden. Wer schon sitzt, bleibt
im Spiel: genau von diesen muss man die neuen unterscheiden können. Dass
die Neuen trotzdem dominieren, besorgt die bestehende Gewichtung aus 5.2 —
ein Gesicht in Box 1 wiegt 25-mal so viel wie eines in Box 5.

Weitere Entscheide:

- **Die Ablenker folgen dem Umfang.** Die Engine sieht ohnehin nur die
  Personen im Spiel. Aus fünf zu wählen ist Lernen, aus vierundzwanzig ist
  Raten — und der erste Durchgang wird dadurch überhaupt erst machbar.
- **Beim manuellen Modus wächst der Umfang mit** (`1`, `1–2`, `1–3`), er
  springt nicht zwischen Portionen. Fünf Gesichter fünfmal zu sehen lehrt
  fünf Namen und keine Klasse.
- **Ein Regler, nicht zwei.** Die Beschriftung trägt die Bedeutung. Ein
  zusätzlicher Schalter „mitwachsend" würde die Chips mehrdeutig machen —
  hiesse „3" dann die dritte Portion oder die ersten drei?
- **Die Portionsgrössen kommen aus der Partitionierung der
  Gruppeneinteilung** (`chunksOf` ruft `partition`), nicht aus stumpfem
  Aufteilen: 21 SuS in Fünfern ergibt 6+5+5+5 statt 5+5+5+5+1. Sonst sässe
  jemand allein in einer Portion und liesse sich gar nicht abfragen.
- **Nur der Umfang überlebt den Neustart**, die Schwierigkeitsregler nicht.
  Wo man steht, ist ein Ort; die Regler sind eine Entscheidung für die
  Runde, die man gerade startet.

Unter dem Rundenregler steht, worauf sich die Karten verteilen — „15 Karten
über 5 Personen — jede etwa 3×" oder, bei der ganzen Klasse, „nicht alle
kommen dran". Die blosse Zahl 15 sagt für sich genommen nichts; erst das
Verhältnis zum Umfang ist die Grösse, um die es geht. Welche Personen im
Spiel sind, holen Runde und Anzeige aus derselben Funktion (`scopeFor`),
damit sie nicht auseinanderlaufen können.

Der automatische Modus hat keine Bedienelemente, zeigt aber, was er tut:
„8 von 26 im Spiel — 3 sitzen, 5 werden gerade gelernt", dazu die Namen der
aktuell Fälligen. Ohne diese Zeile wäre er undurchsichtig statt einfach.

### Aufbau des Setup-Screens

Vier Entscheidungen sichtbar, der Rest zugeklappt:

```
Fortschritt      x von y sicher
Modus            Foto → Name | Name → Foto
Umfang           Automatisch | Selbst einteilen | Ganze Klasse
Schwierigkeit    Leicht | Mittel | Schwer
  ▸ Selbst einstellen   → Optionen, Ablenker, Zeitlimit, Angezeigter Name
Runde            Regler + „15 Karten über 5 Personen"
```

Das Aufklappbare heisst **„Selbst einstellen"** und nicht „Experten" oder
„Feinjustierung": der Umfang darüber trägt bereits „Automatisch / Selbst
einteilen". Zweimal dasselbe Muster verdient zweimal dasselbe Wort — die
App wählt, oder man wählt selbst. Ein zweites Vokabular für dieselbe
Unterscheidung wäre eine Hürde ohne Gegenwert.

Dahinter liegen genau die vier Regler, welche die Voreinstellungen ohnehin
setzen. Alle gleichzeitig zu zeigen macht aus einem Screen, den man
durchquert, ein Formular, das man liest.

**Voreinstellungen ändern nur die Schwierigkeit.** Sie fassen den Umfang
nicht an — ein Tipp auf „Mittel" darf nicht den Lernstand verwerfen, bei
dem man gerade steht. (Genau das tat er vor der Umstellung.)

### Stufen als drei unabhängige Regler

| Regler | Werte |
|--------|-------|
| Anzahl Optionen | 3 / 5 / 8 (Standard 3) |
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

**Fotogrösse und Responsivität.** Die eingebetteten JPEGs sind nur
~200 px im Quadrat — mehr Auflösung ist im PDF nicht vorhanden. Grösser
dargestellt werden sie zwangsläufig weich, deshalb deckelt
`maxPhotoSize` (260 px) die Anzeige; darunter skaliert sie frei mit dem
verfügbaren Platz. Im Quiz bekommt das Foto den grösseren Anteil der
Höhe (`flex: 3` gegen `flex: 2`) und die Antwortliste scrollt bei
Bedarf. **Ohne das kollabiert das Foto auf niedrigen Bildschirmen auf
null Höhe**, weil eine lange Optionsliste den ganzen Platz nimmt — genau
das ist in der ersten Fassung passiert.

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
- Beim Start räumt die App Service Worker ab, die zu einem anderen Pfad
  dieser Domain gehören. Ein solcher Worker bedient seine alte Adresse
  offline weiter, auch wenn der Server dort längst 404 liefert — und dann
  läuft alter Code auf derselben, inzwischen neueren Datenbank. Genau das
  ist beim Umzug von `/namen-lern-app/` auf `/nomen-est/` der Fall.
- Ein eigener Service Worker (`web/sw.js`) hält die App offline lauffähig
  und meldet neue Fassungen über ein Banner. Er ersetzt den von Flutter
  erzeugten; der Deploy stempelt einen Hash der **gebauten Dateien** hinein,
  weil ein Browser eine neue Fassung nur an geänderten Bytes erkennt. Der
  Inhalt und nicht der Commit: der Flutter-Build ist reproduzierbar, also
  lässt eine Änderung an Dokumentation oder Workflow den Hash in Ruhe und
  meldet den Klassen kein Update auf einen identischen Build.
- Der Cache-Name trägt den Pfad, unter dem der Worker liegt. Live-App und
  Preview teilen sich einen Origin und damit einen Cache-Speicher; ohne
  diese Trennung räumte der Worker der einen beim Aktivieren den Cache der
  anderen weg.
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

**Nicht jeder Browser bekommt haltbaren Speicher.** drift sucht sich
beim Start die beste verfügbare Implementierung; OPFS braucht Features,
die eingeschränkte Umgebungen (z. B. eingebettete WebViews) nicht haben,
und fällt dann auf IndexedDB-Varianten zurück. In einem solchen
Fallback-Browser überlebte ein importierter Satz den Reload **nicht** —
die Datenbankdatei blieb bei 56 KB stehen, die Foto-Blobs landeten nie
im dauerhaften Speicher. Auf Android im echten Browser trat das nicht
auf.

→ `DriftWebOptions.onResult` protokolliert die gewählte Implementierung
beim Start in die Konsole (`drift web storage: …`) und legt sie in
`AppDatabase.webStorage` ab. Wenn Datenverlust gemeldet wird, ist das
der erste Blick. Steht dort etwas anderes als eine `opfs…`-Variante,
ist die Persistenz nicht garantiert.

---

## 9. Datenschutz

Es sind Fotos von Jugendlichen. Deshalb:

- Keine Cloud, kein Backend, kein Analytics, keine externen Fonts oder CDNs
- Kein ausgehender Request, der Daten trägt. Seit dem eigenen Service Worker
  fragt die App beim Start und beim Zurückkehren in den Vordergrund an ihrer
  **eigenen** Adresse nach einer neuen Fassung; dabei geht nichts aus der
  Datenbank mit. Sonst gilt unverändert: im Code so halten, dass der
  Flugmodus-Test durchgeht — die App muss ohne Netz vollständig laufen.
- Pro Klassensatz ein "vollständig löschen"-Knopf
- Beim Start des neuen Schuljahrs alte Sätze löschen
- **Die PDFs und exportierten ZIPs niemals ins GitHub-Repo committen.**
  Entsprechende Einträge in `.gitignore` (`*.pdf`, `*.zip`, `/pdfs/`,
  `/testdata/`)
  gleich zu Beginn anlegen.

Falls die Test-PDFs für Unit-Tests im Repo liegen müssten: das Repo
privat halten oder die Tests gegen anonymisierte Dummy-PDFs laufen lassen.

---

## 10. Deployment

Live: **https://masta-nksa.github.io/nomen-est/**
Repo: `masta-nksa/nomen-est`, öffentlich.

- Flutter Web Build → GitHub Pages, automatisch per GitHub Actions bei
  jedem Push auf `master` (`.github/workflows/deploy.yml`). Der Workflow
  lässt vorher `flutter analyze` und `flutter test` laufen.
- Seit der Freigabe wird **im Branch entwickelt und über `preview`
  angesehen**; auf `master` wird nur nach ausdrücklicher Freigabe gemergt.
  Der Ablauf steht in [CLAUDE.md](CLAUDE.md).
- Die Flutter-Version ist im Workflow gepinnt, nicht nur der Kanal. Sonst
  ändert sich die ausgelieferte App ohne Codeänderung, und ein Fehler aus
  einem Flutter-Release landet ungeprüft im Unterricht.
- `--base-href` auf den Repo-Pfad setzen
- `tool/fetch_web_assets.sh` vor dem Build laufen lassen (drift-WASM)
- HTTPS ist über GitHub Pages gegeben und für Service Worker und
  Storage-APIs Voraussetzung
- Optional zusätzlich nativer Android-Build; iOS nativ lohnt sich
  wegen des Apple-Developer-Accounts nicht, dafür ist die PWA da

**Das Repo ist öffentlich, obwohl es um Schülerfotos geht** — der Code
enthält keine Personendaten, und GitHub Pages funktioniert im
Gratis-Tarif nur bei öffentlichen Repos. Die Trennung hält allein
`.gitignore` (Abschnitt 9); die ist damit sicherheitsrelevant.

**Nach einem Deploy hart neu laden** (Strg+Shift+R). Flutter installiert
einen Service Worker, der sonst die alte Version aus dem Cache liefert.

---

## 11. Umsetzungsstand

Schritte 1–10 sind gebaut, auf GitHub Pages deployed und auf Android
sowie im Desktop-Browser getestet.

1. ✅ **`lib/import/pdf_import.dart`** — `parsePdf(Uint8List)`, mit
   Unit-Tests gegen die beiden Beispiel-PDFs
2. ✅ Drift-Schema + Import-Screen mit Klassenname-Abfrage + Review
3. ✅ Foto-Zoom als wiederverwendbare Lightbox (Review, Galerie, Quiz)
4. ✅ Modus 1 (Foto → Name)
5. ✅ Leitner-Boxen + Verwechslungsmatrix
6. ✅ Modus 2 + Galerie
7. ✅ Statistik pro Satz + Auswertung nach der Runde
8. ✅ Stufenregler und Presets
9. ✅ ZIP-Export/-Import
10. ✅ Web-Build + GitHub Pages + PWA-Manifest
11. ⬜ Modi 4–6

Zusätzlich gebaut, obwohl als V2 eingestuft: **Fortschritt
zurücksetzen** (fiel beim Verwaltungs-Menü ohnehin an) — inzwischen als
Untermenü mit vier getrennten Pfaden, siehe
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md).

Danach gebaut: das Kapitel **Zufallsgenerator & Gruppeneinteilung** bis
einschliesslich Beamermodus — Schema-Version 2 mit acht neuen Tabellen und
der Umbenennung aus Abschnitt 4, der Zufallsgenerator mit abgeleitetem Topf,
die Gruppeneinteilung, die Anwesenheit und der Präsentationsmodus für beide.
Einzelheiten und Abweichungen stehen in
[KONZEPT-zufall-und-gruppen.md](KONZEPT-zufall-und-gruppen.md).

Ebenfalls dazugekommen, ausserhalb beider Konzepte:

- **Hell- und Dunkelmodus in NKSA-Orange**, umschaltbar unter „Darstellung"
- **Eigene Icons** (maskable, apple-touch), erzeugt von `tool/gen_icons.py`
- **Eigener Service Worker** statt des von Flutter erzeugten: Offline-Betrieb
  und ein Banner, wenn eine neue Fassung bereitliegt (Abschnitt 8)

### Offener Backlog

Nach Nutzen sortiert, nicht nach Aufwand:

1. **Gruppen speichern** (F4.1 im anderen Konzept). Die eine Lücke, die mehr
   kostet als Komfort: ohne gespeicherte Einteilungen kann keine
   Paarungshistorie entstehen, und ohne die kann die Gruppeneinteilung nie
   berücksichtigen, wer schon zusammengearbeitet hat. Vorbelegung, Rollen und
   Drag & Drop hängen ebenfalls daran. Bis dahin ist jede Einteilung mit dem
   Verlassen des Screens weg.
2. **Statistik-Screen** (F4.4). Füllt die letzte leere Kachel und zeigt, ob die
   Fairness der Ziehung im Alltag hält, was sie verspricht.
3. **Adaptives Lernen** — [KONZEPT-adaptives-lernen.md](KONZEPT-adaptives-lernen.md).
   Ersetzt den automatischen Umfang durch Zu- und Abfluss *innerhalb* der
   Runde: wer sitzt, geht sofort in den Ruhestand, die fälligste Person rückt
   nach, und die Gruppengrösse folgt der Serie richtiger Antworten. Behebt drei
   beobachtete Schwächen — der Zufluss kommt in Sprüngen, Gelernte belegen
   weiter Karten, und nichts kommt je zur Wiederholung zurück.
4. **Ein „Nächster Schritt"-Knopf** auf dem Auswertungsscreen, damit man nach
   einer Runde nicht über das Setup gehen muss.
5. **Vergleichsmodus** `↩ vorher` (F3.6). Macht Neuwürfeln risikofrei.
6. Modi 4–9 (Tippen, Speed-Runde, Zuordnungsraster, Fokus-Runde,
   Verwechslungs-Vergleich, Freies Nennen), Sortieren/Suchen in der
   Klassenliste, Undo-Snackbar nach dem Löschen, Mehrfach-Import am Stück.

### Wünsche aus dem Gebrauch

Aufgenommen, nicht entschieden — Umsetzung und Reihenfolge sind noch offen.
Die Hinweise darunter sind das, was bei der Aufnahme auffiel, keine Zusage.

- **Klasse nach dem Import bearbeiten, vor allem Fotos ersetzen.** Wer einen
  SPF-Kurs übernimmt, sieht die Klasse im 3. GYM wieder, beim EF im 4. GYM —
  die Fotos aus dem PDF sind dann ein bis zwei Jahre alt. Wer sich stark
  verändert hat, ist darauf kaum wiederzuerkennen, und die App übt dann ein
  Gesicht ein, das es so nicht mehr gibt.
- **Personen ohne Foto aufnehmen und ein Bild nachtragen.** Neuzuzüger/innen
  erscheinen in der Schulverwaltung in der Regel nie mit Foto; bisher bleibt
  von ihnen nur der Name. Setzt eine Schemaänderung voraus: `jpegBytes` ist
  heute `blob()` und damit Pflicht — eine Person ohne Bild lässt sich gar
  nicht speichern.
- **Ablenker nur aus demselben Geschlecht.** Setzt ein Feld voraus, das es
  nicht gibt: weder das Schema noch das PDF kennen ein Geschlecht. Es müsste
  also von Hand gesetzt oder geraten werden — Letzteres verbietet sich bei
  Jugendlichen von selbst.
- **Klassenübergreifend üben**, etwa die 15 schwierigsten über alle Klassen
  hinweg oder einfach 15 zufällige. Datenseitig bereits möglich: `Progress`
  und `Confusions` hängen an der Person, nicht an der Klasse. Im Weg stehen
  nur die Screens, die durchweg von einer Klasse ausgehen.

### Entscheide, die bewusst offen sind

- **Quiz-Regler werden nicht gespeichert**, nur der Umfang. Modus,
  Schwierigkeit und Rundenlänge stehen bei jedem Start auf ihrem Standard.
  Falls sich das im Gebrauch als lästig zeigt, ist es dieselbe Mechanik wie
  beim Umfang.
- **Vorbelegung sessionübergreifend speichern:** nein, Wiederverwendung läuft
  über gespeicherte Einteilungen (F4.5).
- **Zerfall der Paarungshistorie:** erst ohne bauen, nachrüsten wenn nötig.

### Gefundene Bugs, die dokumentiert bleiben sollen

Vier Fehler sind erst nach dem ersten Bauen aufgefallen — sie sind
behoben, aber die Muster lohnen die Erinnerung:

1. **Use-after-free im Import.** `PdfImage.pixels` ist nur ein View auf
   malloc'ten Speicher, den `dispose()` freigibt. Die Foto-Ausschnitte
   entstanden danach. Ging in Tests zufällig gut, weil der freigegebene
   Heap die Daten noch enthielt. → Pixel vor dem `dispose()` kopieren.
2. **Gewichtung wirkungslos** (Abschnitt 5.2).
3. **Zwei Web-Fehler**, die Tests nicht sehen konnten (Abschnitt 2).
4. **Foto auf null Höhe** bei knapper Bildschirmhöhe (Abschnitt 7).
5. **Migration, die nur einmal laufen konnte.** Drift führt Migrationen
   ohne Transaktion aus und schreibt die neue Versionsnummer erst nach
   dem letzten Schritt. Bricht einer ab, bleiben die vorherigen
   angewandt, die Version bleibt alt, und der nächste Start beginnt von
   vorn — auf einer halb umgebauten Datenbank. Ein `ALTER TABLE`, das
   beim ersten Mal geklappt hat, tötet dann jeden weiteren Start, und
   die App ist unbenutzbar. → Migrationsschritte an den *tatsächlichen*
   Schemazustand knüpfen (`sqlite_master`, `pragma_table_info`), nicht
   an die Versionsnummer. Merke fürs nächste Schema: **eine Migration
   muss wiederholbar sein.** Und: drift generiert `CREATE INDEX` ohne
   `IF NOT EXISTS` — Indizes deshalb als explizites SQL deklarieren.
6. **Verschluckte Ausnahme beim Speichern.** Ohne `catch` sah ein
   Datenbankfehler im Import aus wie ein Knopf, der nichts tut. Jede
   `await`-Kette, an deren Ende der Benutzer auf etwas wartet, braucht
   einen sichtbaren Fehlerpfad.

7. **Ein verrutschtes Foto kostete alle Vornamen.** Die Breite des
   Suchfensters für Namen war der *kleinste* Abstand zwischen zwei
   Foto-Randkanten der Seite. Ein Foto, das 18 px schmaler war und 19 px
   neben seiner Spalte sass, drückte diesen Wert von 275 px auf 19 px —
   das Fenster schrumpfte auf 6.8 pt und jede Person auf der Seite behielt
   nur ihr erstes Wort. Dasselbe Foto verlor seinen Namen ganz, weil sein
   Fenster rechts vom eigenen Text begann. → Randkanten, die näher als
   eine halbe Fotobreite beieinanderliegen, gehören zur selben Spalte;
   gesucht wird ab der Spaltenkante, nicht ab der Fotokante. Merke:
   **kein Mass aus einem Minimum über alle Elemente ableiten**, wenn ein
   einzelner Ausreisser es beliebig klein machen kann.
8. **Weisse Balken unter Fotos.** Ein Zeilenband ist so hoch wie sein
   höchstes Foto, und nicht jede Klasse gibt gleich grosse Bilder ab. →
   Jede Box wird in ihrer eigenen Spalte senkrecht nachgemessen. Die
   Bandunterkante bleibt daneben erhalten, weil die Namen an der Zeile
   hängen und nicht am Foto.

---

## 12. Tests

`flutter test` deckt den Lernmodus, den Import, die Unterrichtswerkzeuge
und die Darstellung ab (Stand: 242 Tests):

| Datei | Inhalt |
|-------|--------|
| `pdf_import_test.dart` | Parser gegen die echten PDFs, Spaltenerkennung, Namenszeilen, Fotobeschnitt |
| `chunks_test.dart`, `quiz_setup_screen_test.dart` | Häppchen: Aufteilung, Wahl, Merken |
| `database_test.dart` | Drift: Leitner-Bewegung, Verwechslungen, Kaskaden-Löschen, die vier Resets |
| `migration_test.dart` | v1 → v2: Umbenennung, erhaltene Daten, wiederholbare Migration |
| `quiz_engine_test.dart` | Fragenauswahl, Distraktoren, Gewichtung |
| `class_archive_test.dart` | ZIP-Export/-Import Round-Trip |
| `selection_engine_test.dart`, `selection_repository_test.dart` | Ziehung: Topf, Cooldown, Fairness, Anwesenheit, Undo |
| `partition_test.dart`, `group_builder_test.dart` | Gruppengrössen und Zuteilung, reine Logik |
| `draw_screen_test.dart`, `groups_screen_test.dart`, `attendance_screen_test.dart` | die drei Unterrichtsscreens |
| `mode_chip_bar_test.dart`, `presentation_test.dart` | Chip-Leiste und Beamermodus |
| `app_theme_test.dart`, `appearance_test.dart`, `update_banner_test.dart` | Farbschema, Darstellungswahl, Update-Hinweis |
| `classes_screen_test.dart` | Klassenverwaltung |
| `widget_test.dart` | Startseite |

Die Parser-Tests brauchen die echten PDFs in `pdfs/`. Fehlen die (etwa
in CI, wo sie bewusst nicht liegen), **überspringen sie sich selbst**
statt zu scheitern.

**Falle bei Widget-Tests:** `pumpAndSettle()` wartet, bis keine Frames
mehr angefordert werden — ein `CircularProgressIndicator` fordert sie
endlos an. Zeigt ein Screen im Ladezustand einen Kreisel, hängt der Test
minutenlang, statt zu scheitern. Abhilfe: die Daten des Ladezustands im
Test vorab bereitstellen (Provider mit `Stream.value` überschreiben),
sodass der Kreisel gar nicht erst erscheint.

### Testfälle für den Parser

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
