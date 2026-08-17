# Nomen est — Kapitel: Zufallsgenerator & Gruppeneinteilung

*Ergänzung zu `KONZEPT-namen-lern-app.md`*

> **Stand:** F0.2 (Datenmodell und Migration) ist gebaut, alles Weitere offen.
> Wo die Umsetzung vom Entwurf abweicht, steht der Grund an Ort und Stelle
> unter „Gebaut:".

---

## 1. Überblick

Zwei neue Unterrichtswerkzeuge auf derselben Datenbasis wie der Lernmodus (Klasse → SuS mit Foto und Name):

- **Zufallsgenerator** — eine/n SuS ziehen, mit oder ohne Zurücklegen
- **Gruppeneinteilung** — Klasse in Gruppen aufteilen, immer ohne Zurücklegen, wahlweise mit manueller Vorbelegung einzelner Plätze

Beide teilen sich Infrastruktur: Pool-Ermittlung, Anwesenheit, Historie, Präsentationsdarstellung. Das wird bewusst als **eine** `SelectionEngine` gebaut, nicht als zwei parallele Implementierungen — sonst driften Anwesenheitslogik und Fairness auseinander.

### Leitprinzip zur Persistenz

„Ohne Zurücklegen" wird **nicht** als Flag am Schüler gespeichert, sondern als Ereignis-Log. Der Pool ist eine abgeleitete Grösse:

> Pool = alle SuS der Klasse − seit dem letzten Reset Gezogene − heute Abwesende

Vorteile: sessionübergreifend ohne Zusatzaufwand, Undo und Statistik fallen gratis ab, ein Reset ist ein einziger Insert (keine Massen-Updates), und die Historie bleibt für die Fairness-Gewichtung erhalten.

---

## 2. Navigation & Klassenkontext

Die Klasse ist **globaler, persistenter Kontext** — nicht pro Feature neu zu wählen. Alle drei Features brauchen sie ohnehin.

```
┌─────────────────────────────┐
│  Klasse:  [ 2c Mathe   ▾ ]  │  ← zuletzt genutzte, gemerkt
├─────────────────────────────┤
│  ┌────────┐  ┌────────┐     │
│  │ Namen  │  │ Zufall │     │
│  │ lernen │  │        │     │
│  └────────┘  └────────┘     │
│  ┌────────┐  ┌────────┐     │
│  │Gruppen │  │Statis- │     │
│  │        │  │ tik    │     │
│  └────────┘  └────────┘     │
├─────────────────────────────┤
│  Anwesenheit heute: 22/24 ▸ │  ← ein Tipp, überall gültig
└─────────────────────────────┘
```

Die Anwesenheitszeile ist bewusst auf dem Startscreen und nicht in jedem Feature versteckt: einmal pro Lektion antippen, dann gilt sie für Ziehung und Gruppen gleichermassen.

**Gebaut (F0.1)**, mit drei Abweichungen:

- **Die Anwesenheitszeile fehlt noch.** Sie gehört zu F3.1; eine Zeile zu zeigen,
  hinter der nichts liegt, wäre eine Attrappe.
- **Import und Klassenverwaltung liegen hinter einem Zahnrad in der AppBar.**
  Der Entwurf zeigt vier Kacheln und sagt nicht, wo die Verwaltung bleibt. Sie
  ist ein- bis zweimal pro Semester nötig und darf den Unterrichtsalltag nicht
  nach unten drängen.
- **Der Klassen-Picker ist weg.** Er wurde vom globalen Klassenkontext
  überflüssig; sein einziger verbliebener Zweck, der Galerie-Zugang, sitzt jetzt
  in der AppBar des Quiz-Setups, wo die Galerie hingehört.

Die drei noch nicht gebauten Kacheln bleiben sichtbar und tragen ein Label
(„kommt als Nächstes", „später"). Eine leere Kachel, die nichts tut, liest sich
als Fehler — eine beschriftete als Fahrplan.

Die zuletzt gewählte Klasse steht unter `app.selectedClass` in `Settings`. Zeigt
der gespeicherte Wert ins Leere, weil die Klasse gelöscht wurde, fällt die
Auswahl auf den jüngsten Import zurück.

---

## 3. Datenmodell (Drift)

**Gebaut, mit vier Abweichungen vom Entwurf** (Schema-Version 2, alles in
`lib/data/database.dart`):

1. **`Classes` und `Students` statt `PhotoSets` und `Persons`.** Der Entwurf
   unten schreibt bereits `Classes`/`Students`; der Bestand hiess anders, weil
   ein Satz aus einem PDF-Import entstand. Anwesenheit, Ziehungen und Gruppen
   gehören aber zur Klasse, nicht zum Import — deshalb umbenannt, solange es
   noch billig war. Die Drift-Datenklasse heisst `SchoolClass`, weil `Class` in
   Dart nicht geht.
2. **`Students.active`** (bool, Default true), im Entwurf nicht vorgesehen. Wer
   die Klasse mitten im Jahr verlässt, wird deaktiviert statt gelöscht: ein
   Löschen würde über die Kaskade den Ziehungsverlauf und die gespeicherten
   Gruppen mitnehmen und damit eine Historie umschreiben, die stattgefunden hat.
   Inaktive fallen aus Pool und Quiz, ihr Log bleibt lesbar.
3. **`Absences.day` ist ein `IntColumn`** im Format `20260816`, kein `DateTime`.
   Drift legt `DateTime` als UTC-Instant ab; „heute" verschöbe sich damit über
   eine Zeitzonen- oder Sommerzeitgrenze. Helfer: `dayNumber(DateTime)`.
4. **Alle Fremdschlüssel kaskadieren** (`onDelete: KeyAction.cascade`). Ohne das
   scheitert „Klasse löschen" an `PRAGMA foreign_keys = ON`, sobald die erste
   Ziehung protokolliert ist.

Die Migration von Version 1 benennt um und legt an, statt neu zu erstellen —
Fotos und Lernfortschritte überleben sie. `test/migration_test.dart` öffnet eine
von Hand aufgebaute v1-Datenbank und prüft genau das.

**Preview-Deployment und Browser-Speicher.** Der `preview`-Branch wird unter
`/namen-lern-app/preview/` ausgeliefert (siehe `.github/workflows/deploy.yml`).
IndexedDB und OPFS hängen aber am **Origin**, nicht am Pfad: Preview und Live-App
öffnen dieselbe `nomen_est`-Datenbank. Ein zweites Repo würde daran nichts
ändern, `masta-nksa.github.io` bleibt derselbe Origin.

Das ist gewollt — so testet die Preview die Migration auf echten Klassen, was
sonst nirgends möglich ist. Der Preis: danach steht die Datenbank auf Version 2
und der ältere Master-Build bricht beim Öffnen ab, bis gemergt ist. Gelöscht
wird nichts. Wer die Trennung doch braucht, gibt dem Preview-Build über
`String.fromEnvironment('DB_NAME')` und `--dart-define` einen eigenen
Datenbanknamen — dann testet er die Migration allerdings nicht mehr.

### 3.1 Neue Tabellen

```dart
/// Jede einzelne Ziehung. Nie löschen (ausser Undo), nie überschreiben.
class DrawEvents extends Table {
  IntColumn      get id        => integer().autoIncrement()();
  IntColumn      get classId   => integer().references(Classes, #id)();
  IntColumn      get studentId => integer().references(Students, #id)();
  TextColumn     get poolKey   => text().withDefault(const Constant('default'))();
  DateTimeColumn get drawnAt   => dateTime()();
}

/// Markiert den Beginn einer neuen Runde „ohne Zurücklegen".
class PoolResets extends Table {
  IntColumn      get id      => integer().autoIncrement()();
  IntColumn      get classId => integer().references(Classes, #id)();
  TextColumn     get poolKey => text().withDefault(const Constant('default'))();
  DateTimeColumn get resetAt => dateTime()();
  BoolColumn     get auto    => boolean().withDefault(const Constant(false))();
}

/// Nur Abwesende werden gespeichert — Default ist anwesend.
class Absences extends Table {
  IntColumn  get classId   => integer().references(Classes, #id)();
  IntColumn  get studentId => integer().references(Students, #id)();
  DateColumn get day       => ...;   // Drift: DateTimeColumn, auf Tag normalisiert
  @override Set<Column> get primaryKey => {classId, studentId, day};
}

/// Eine gespeicherte Gruppeneinteilung.
class GroupSets extends Table {
  IntColumn      get id        => integer().autoIncrement()();
  IntColumn      get classId   => integer().references(Classes, #id)();
  TextColumn     get label     => text()();          // „Projekt Vektorgeometrie"
  DateTimeColumn get createdAt => dateTime()();
}

class GroupMembers extends Table {
  IntColumn  get groupSetId => integer().references(GroupSets, #id)();
  IntColumn  get groupIndex => integer()();          // 0-basiert
  IntColumn  get studentId  => integer().references(Students, #id)();
  TextColumn get role       => text().nullable()();  // „Protokoll"
  @override Set<Column> get primaryKey => {groupSetId, studentId};
}

/// Denormalisierter Cache: wie oft waren a und b zusammen?
/// Invariante: immer studentA < studentB.
class PairCounts extends Table {
  IntColumn      get classId  => integer().references(Classes, #id)();
  IntColumn      get studentA => integer().references(Students, #id)();
  IntColumn      get studentB => integer().references(Students, #id)();
  IntColumn      get count    => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAt   => dateTime().nullable()();
  @override Set<Column> get primaryKey => {classId, studentA, studentB};
}

/// Harte Regeln der Lehrperson.
class GroupConstraints extends Table {
  IntColumn  get id       => integer().autoIncrement()();
  IntColumn  get classId  => integer().references(Classes, #id)();
  IntColumn  get studentA => integer().references(Students, #id)();
  IntColumn  get studentB => integer().references(Students, #id)();
  TextColumn get kind     => textEnum<ConstraintKind>()();  // together | apart
  TextColumn get note     => text().nullable()();
}
```

### 3.2 Indizes

```sql
CREATE INDEX idx_draw_class_pool_time ON draw_events (class_id, pool_key, drawn_at DESC);
CREATE INDEX idx_draw_student         ON draw_events (class_id, student_id);
CREATE INDEX idx_absence_day          ON absences    (class_id, day);
```

**Gebaut** als `@TableIndex`-Annotationen an den Tabellen, **ohne** `DESC`:
SQLite läuft einen Index auch rückwärts, `ORDER BY drawn_at DESC` profitiert
also gleich. Dass die Indizes auf beiden Wegen entstehen — Neuinstallation *und*
Migration — prüfen zwei Tests, weil die Migration sie in einer eigenen Schleife
anlegt und ein Vergessen sonst erst als langsame Pool-Query auffiele.

`PairCounts` ist aus `GroupMembers` rekonstruierbar — deshalb bei jeder Migration ein Rebuild-Pfad vorsehen, statt der Konsistenz zu vertrauen.

### 3.3 `poolKey`

Erlaubt mehrere unabhängige Töpfe pro Klasse: `default` (Aufrufen im Unterricht), `praesentation`, `tafeldienst`. In Stufe 1 fix auf `default`, die Spalte ist aber von Anfang an da — nachträglich einzuziehen wäre eine Migration mit Datenumschreibung.

---

## 4. Algorithmen

### 4.1 Pool-Ermittlung

```
pool(classId, poolKey, heute):
    letzterReset ← max(resetAt) aus PoolResets für (classId, poolKey)  ?? 1970-01-01
    gezogen      ← { studentId aus DrawEvents | classId, poolKey, drawnAt > letzterReset }
    abwesend     ← { studentId aus Absences   | classId, day = heute }
    return alle(classId) \ gezogen \ abwesend
```

**Wichtig:** Abwesende erzeugen kein `DrawEvent`. Sie verbrauchen den Pool nicht und sind beim nächsten Mal wieder dran. Das ist der Grund, warum Anwesenheit *vor* der Ziehung stehen muss und nicht nachträglich korrigiert wird.

**Pool leer:** Dialog „Alle 24 waren dran — neue Runde starten?" → Reset mit `auto = false`. Optional in den Einstellungen: automatischer Reset ohne Nachfrage (`auto = true`), dann sieht die Statistik trotzdem, wo eine Runde endete.

### 4.2 Ziehung

```
ziehe(pool, m, cooldownK, alpha):
    // Cooldown ist weich: lieber wiederholen als gar nichts liefern
    letzte    ← die letzten cooldownK studentIds aus DrawEvents (classId, resetübergreifend)
    kandidaten ← pool \ letzte
    if kandidaten = ∅: kandidaten ← pool

    // Gewichtung über die gesamte Historie, nicht nur die aktuelle Runde
    für i in kandidaten:
        count_i ← |DrawEvents(classId, studentId = i)|
    maxC ← max(count_i)
    w_i  ← (1 + maxC − count_i)^alpha

    gezogene ← m-mal ohne Zurücklegen proportional zu w gezogen
    schreibe für jede/n ein DrawEvent   // auch im Modus „mit Zurücklegen"!
    return gezogene
```

Zwei Feinheiten:

1. **Auch „mit Zurücklegen" schreibt Events.** Sonst ist die Statistik löchrig und die Fairness-Gewichtung blind. Der Modus steuert nur, ob `gezogen` den Pool filtert.
2. **α steuert die Härte.** α = 0 → Gleichverteilung. α = 1 → weiche Bevorzugung der Selteneren. α = 2 → deutlich. Im Modus „ohne Zurücklegen" ist α irrelevant, weil der Pool die Fairness schon erzwingt.

**Entschieden:** `count_i` zählt **pro `poolKey`**, nicht klassenweit. Der
Pseudocode oben lässt `poolKey` weg — dann käme jemand im Unterricht seltener
dran, weil er oft zum Tafeldienst gezogen wurde. Spätestens ab F6.4 wäre das
eine unerklärliche Verzerrung.

### 4.3 Gruppenzahl aus einem Grössenbereich

Für n SuS und Bereich [min, max]:

```
gueltigeGruppenzahlen(n, min, max) = { g | ⌈n/max⌉ ≤ g ≤ ⌊n/min⌋ }
```

Ist die Menge leer (z. B. n = 7, Bereich 4–5), Fehlermeldung mit konkretem Vorschlag statt generischem „nicht möglich": „7 SuS lassen sich nicht in Gruppen von 4–5 teilen. Möglich: 3–4 (zwei Gruppen) oder eine Restgruppe zulassen."

**Default-g:** dasjenige, das der Bereichsmitte am nächsten kommt —

```
g* = clamp( round( n / ((min+max)/2) ), gueltigeGruppenzahlen )
```

Ein Slider zeigt die Alternativen mit ihrer Konsequenz („8 Gruppen: 7×3 + 1×2").

**Grössenverteilung bei „gleichmässig verteilen" (empfohlener Default):**

```
basis = n div g ;  rest = n mod g
→ rest Gruppen der Grösse (basis+1), (g − rest) Gruppen der Grösse basis
```

Grössenunterschied damit garantiert ≤ 1.

**Ohne „gleichmässig verteilen":** greedy mit max füllen, der Rest bildet eine kleinere Gruppe. Bei n = 25 und fixer Grösse 4: gleichmässig → 5×5 oder 6 Gruppen à 4–5; ungleichmässig → 6×4 + 1×1. Genau dieser Unterschied rechtfertigt die Option — manchmal *will* man sechs saubere Vierergruppen und eine Einzelperson, die zu einer dazustösst.

*Beispiel n = 23, Bereich 2–3:* gültig sind g ∈ {8 … 11}. Mitte 2.5 → g\* = 9 → 5 Dreier + 4 Zweier.

### 4.4 Zuteilung mit Historie und Constraints

Eine einzige Kostenfunktion deckt Paarungshistorie *und* Constraints ab:

```
kosten(einteilung) =  W_hart · anzahlVerletzterApartRegeln
                    + Σ über Gruppen Σ über Paare (a,b) in Gruppe  pairCount[a][b]

mit W_hart = 10 000   (dominiert jede Historie)
```

```
bildeGruppen(pool, zielGroessen, pins, constraints, pairCounts):
    // "together"-Regeln vorab auflösen — sie sind transitiv
    bloecke ← unionFind(pool, constraints.together)

    // Vorbelegung auf Blöcke übertragen
    für jeden block:
        fixierteGruppen ← { pins[s] | s ∈ block, s ist vorbelegt }
        if |fixierteGruppen| > 1:
            Fehler: „A ist fix in Gruppe 1, B fix in Gruppe 3 — beide müssen
                     aber zusammen. Regel oder Vorbelegung anpassen."
        if |fixierteGruppen| = 1:
            block.fixiertAuf ← das einzige Element   // ganzer Block wandert mit

    if max(|block|) > max(zielGroessen):
        Fehler: „A+B+C müssen zusammen, passen aber in keine Gruppe der Grösse …"

    freieBloecke ← { b | b.fixiertAuf = null }

    bestes ← null
    wiederhole R = 200 mal:               // Zufallsneustarts
        e ← fixierte Blöcke auf ihre Gruppe setzen        // unveränderlich
             + freieBloecke zufällig auf die Restkapazität verteilen
        wiederhole bis keine Verbesserung:
            prüfe alle Tausche zwischen zwei *freien* Blöcken,
            die die Zielgrössen erhalten
            führe den kostensenkendsten Tausch aus
        bestes ← argmin(kosten, bestes, e)
    return bestes
```

Die fixierten Blöcke werden nie getauscht, gehen aber voll in `kosten()` ein — die freien SuS werden also aktiv *um* die Vorbelegung herum optimiert. Wer fix in Gruppe 1 sitzt, zieht die passenden Freien an und die Historie-Belasteten weg.

### 4.5 Vorbelegung: Grössen und Machbarkeit

Vorbelegte Plätze sind **Untergrenzen** für die jeweilige Gruppengrösse. Bei vorgegebener Gruppenzahl g und n anwesenden SuS mit p_i Vorbelegungen in Gruppe i:

```
verteileGroessen(n, g, p, gleichmaessig):
    if Σp_i > n:  Fehler (mehr vorbelegt als anwesend)

    if gleichmaessig:
        basis ← n div g ;  rest ← n mod g
        // machbar genau dann, wenn:
        if max(p_i) > basis + 1  oder  |{ i : p_i > basis }| > rest:
            Fehler + Vorschlag
        sortiere Gruppen nach p_i absteigend
        die ersten `rest` Gruppen bekommen basis+1, alle übrigen basis
    else:
        s_i ← p_i   // Untergrenze
        verteile die n − Σp_i freien SuS greedy auf die jeweils kleinste Gruppe
        (bei Bereichsvorgabe: bis max erreicht ist)
```

Dass bei „gleichmässig" die Gruppen mit **den meisten** Vorbelegungen die grösseren werden, ist kein Detail: sonst scheitert die Verteilung an Fällen, die eigentlich lösbar sind.

Beispiele:

| n | g | Vorbelegung | Ergebnis |
|---|---|---|---|
| 24 | 6 | 2 in G1 | 6×4, G1 hat 2 fix + 2 zufällig |
| 25 | 6 | 5 in G1 | basis 4, rest 1 → G1 = 5 (voll fix), 5×4 |
| 25 | 6 | 5 in G1, 5 in G2 | Fehler: nur eine Gruppe darf 5 sein |
| 24 | 6 | 5 in G1 | Fehler: max 4 pro Gruppe bei 6 Gruppen |

Fehlermeldungen nennen immer den Ausweg: *„5 SuS fix in Gruppe 1, bei 6 Gruppen sind aber höchstens 4 möglich. Vorschlag: 5 Gruppen bilden oder ungleichmässige Grössen zulassen."*

### 4.6 Vorrangregeln

Wenn sich Vorbelegung, Constraints und Historie widersprechen:

1. **Manuelle Vorbelegung** gewinnt immer — sie ist die jüngste, bewussteste Entscheidung
2. **Constraints** (`together` / `apart`) gewinnen gegen die Historie
3. **Paarungshistorie** ist reine Präferenz und wird notfalls verletzt

Konkret: Wer A und B beide fix in Gruppe 2 setzt, obwohl eine `apart`-Regel existiert, bekommt eine Warnung („A und B sollten laut Regel getrennt sein") — aber keine Blockade. Nur *strukturelle* Unmöglichkeiten (Kapazität, widersprüchliche `together`-Ketten) werden hart abgewiesen.

**Abwesende:** Eine vorbelegte Person, die als abwesend markiert wird, verliert ihre Fixierung automatisch — mit einem Hinweis, nicht stillschweigend.

Bei n ≤ 30 sind 200 Neustarts mit lokaler Suche in wenigen Millisekunden durch — kein Grund für etwas Ausgefeilteres. Falls doch spürbar: `compute()` in einen Isolate.

**Nach dem Bestätigen** (nicht schon beim Würfeln!) `pairCount[a][b] += 1` für alle Paare innerhalb einer Gruppe, plus `lastAt`. Sonst zählt jedes Neu-Würfeln mit.

**Optionaler Zerfall:** `effektivesGewicht = count · 0.9^(Monate seit lastAt)`. Damit blockiert eine Paarung vom Schuljahresanfang nicht das ganze Jahr. Erst einbauen, wenn sich das in der Praxis als Problem zeigt.

---

## 5. Screens

| Screen | Inhalt |
|---|---|
| **Start** | Klassenwahl, vier Kacheln, Anwesenheitszeile |
| **Anwesenheit** | Foto-Grid, Tippen = ausgegraut, „alle da"-Button |
| **Zufall** | Modusschalter mit/ohne Zurücklegen, Poolzähler „17 von 24", grosser Würfel-Button, Reset im Menü |
| **Ergebnis** | Vollbild Foto + Name, Undo, „nochmal" |
| **Gruppen-Setup** | Geführter Flow, siehe unten |
| **Gruppen-Ergebnis** | Karten pro Gruppe mit Foto-Chips, Drag & Drop, Rollen, Neu würfeln, Speichern, Export |
| **Statistik** | Balken „wie oft gezogen" pro SuS, Paarungsmatrix als Heatmap |
| **Constraints** | Liste der Regeln, Hinzufügen über zwei Foto-Picker |

### Geführter Setup-Flow

```
① Klasse          2c Mathe            [aus globalem Kontext, nur bestätigen]
② Anwesenheit     22 von 24 anwesend  [überspringbar]
③ Aufteilung      ( ) Anzahl Gruppen:  [ 6 ]
                  ( ) Gruppengrösse:   [ 4 ]
                  ( ) Grössenbereich:  [2]–[3]
                  [x] gleichmässig verteilen
                  → „ergibt 6 Gruppen à 3–4"
④ Vorbelegung     Fotoleiste unten, Gruppenkarten oben
                  Foto in Karte ziehen = fix        [überspringbar]
⑤ Würfeln         → Ergebnisscreen
```

Schritt ① ist meist nur eine Bestätigung, weil die Klasse global gesetzt ist — aber er bleibt sichtbar, damit der Wechsel innerhalb des Flows möglich ist. Klasse steht immer vor allem anderen, weil Anwesenheit, Gruppenzahl-Vorschlag und Vorbelegung alle von ihr abhängen.

Zwei Dinge, die den Flow im Alltag rettet oder ruiniert:

- **Ein „Direkt würfeln"-Button ist ab Schritt ③ permanent sichtbar.** Der Normalfall ist *keine* Vorbelegung; wer sie nie braucht, darf nicht durch einen Extra-Screen laufen.
- **Rückwärtsnavigation verliert nichts.** Von ④ zurück nach ③, um auf 7 Gruppen zu wechseln, behält alle Fixierungen, die noch in gültige Gruppen passen. Die anderen landen zurück in der Fotoleiste, mit Hinweis.

In Schritt ④ zeigt jede Gruppenkarte die berechnete Zielgrösse als Kapazität an („2 / 4"), damit man beim Setzen sieht, wie viel Spielraum bleibt. Karten, die durch die Vorbelegung unmöglich werden, färben sich sofort ein — nicht erst beim Würfeln.

**Vorbelegung aus einer gespeicherten Einteilung laden** (setzt F4.1 voraus): „Gruppen wie beim letzten Projekt, aber Lisa und Tim tauschen" ist ein sehr häufiger Fall. Alte Einteilung als Ausgangslage laden, zwei Karten verschieben, Rest neu würfeln.

### Präsentationsmodus

Querformat, Fotos gross, Schrift ab 48 pt, kein Chrome. Aktiviert sich bei Landscape automatisch oder per Vollbild-Button. Für iPad am Beamer gedacht.

### Foto-zuerst-Auflösung

Beim Ziehen erscheint zunächst nur das Foto; Tippen legt den Namen frei. Kleiner Kniff mit grossem Effekt: Der Zufallsgenerator wird selbst zum Lernwerkzeug, weil man in der realen Situation abruft — genau das, was der Lernmodus trainiert.

---

## 6. Inline-Einstellungen: die Chip-Leiste

### 6.1 Was gehört in den Workflow, was in die Einstellungen?

Drei Kriterien — eine Einstellung gehört inline, wenn **mindestens zwei** zutreffen:

1. Sie wird häufiger als einmal pro Woche geändert
2. Ihr Zustand verändert das Ergebnis so, dass man ihn beim Bedienen kennen muss
3. Der Effekt ist sofort sichtbar, das Umschalten also ein Test

„Mit / ohne Zurücklegen" erfüllt alle drei. Die Fairness-Gewichtung α erfüllt nur das dritte — sie gehört in die Einstellungen, *aber mit einer Ausnahme*, siehe 6.3.

### 6.2 Drei Chip-Stufen

**① Modus-Chips** — immer sichtbar, bestimmen *was* die Funktion tut. Gefüllt = aktiv, Umriss = inaktiv.

**② Status-Chips** — immer sichtbar, zeigen Zahlen statt Zuständen (`Pool 17/24`, `22/24 da`, `3 fix`). Tippen springt zum zugehörigen Detail, statt zu schalten.

**③ Feinjustierung** — hinter einem `⋯`-Chip. Cooldown-Länge, α, Anzahl Neustarts.

### 6.3 Die wichtigste Regel

> **Ein Nicht-Default-Wert ist nie unsichtbar.**

Steht eine Feinjustierung auf ihrem Standard, lebt sie hinter `⋯`. Weicht sie ab, rutscht sie als eigener Chip in die Leiste — `Fairness streng`, `Pause aus`, `Regeln ignoriert`.

Damit ist der klassische Fehlerfall ausgeschlossen: „Der Generator zieht immer dieselben" drei Wochen nachdem man α versehentlich auf 0 gesetzt hat. Die Leiste ist gleichzeitig Bedienelement *und* Diagnose — man sieht auf einen Blick, warum sich die Funktion so verhält, wie sie sich verhält.

### 6.4 Platzierung und Interaktion

Eine horizontal scrollbare Reihe **direkt über dem Hauptaktionsbutton**, auf jedem Screen an derselben Stelle. Unten, weil dort der Daumen ist und weil oben schon der Klassenkontext sitzt.

- **Tippen** = umschalten, sofort wirksam, keine Bestätigung
- **Lange drücken** = kurze Erklärung plus Optionen (bei ⋯-Werten: Slider/Stepper)
- **Kein Zustandsverlust:** „ohne Zurücklegen" aus- und wieder einschalten lässt den Pool unberührt. Das ist Voraussetzung dafür, dass Umschalten sich als Test anfühlt und nicht als Risiko.
- Visuell dezent (ca. 28 pt hoch, gedämpfte Farbe), **Tippfläche trotzdem mindestens 44 pt**. Dezent heisst leise, nicht schwer zu treffen.

### 6.5 Icons und Beschriftung

**Selbsterklärend und schlicht sind bei abstrakten Zuständen ein Zielkonflikt.** Für „Foto", „Gruppe" oder „Pin" gibt es etablierte Bildzeichen. Für „Ziehen ohne Zurücklegen" gibt es keines — jeder Versuch endet als Rebus, den man einmal erklärt bekommen muss und danach auswendig kann. Das ist kein selbsterklärendes Icon, sondern ein gelerntes.

Daraus folgen drei Regeln:

**① Modus-Chips tragen Icon *und* Kurzlabel.** Ein bis zwei Wörter. Icon-only nur bei Status-Chips, wo die Zahl das Label ist. Das kostet Breite, aber die Leiste scrollt ohnehin — und ein Chip, den man antippen muss um zu wissen was er tut, ist schlimmer als ein breiter Chip.

**② Jeder Chip ist ein An/Aus eines positiv formulierten Begriffs.** Kein Chip, der zwischen zwei Icons wechselt: das ist die Play/Pause-Falle — zeigt das Symbol den aktuellen Zustand oder die Wirkung des Tippens? Stattdessen: ein Icon, ein Begriff, Füllung als Zustandsachse. Gefüllt = an, Umriss = aus.

Diese Regel hat drei Chips umbenannt, damit ein Icon überhaupt greifen kann:

| bisher | neu | warum |
|---|---|---|
| `mit / ohne Zurücklegen` | `Wiederholung` (aus = Standard) | Zwei-Zustands-Modus wird ein An/Aus. Ein `repeat`-Symbol ist aus jedem Musikplayer bekannt. |
| `Foto zuerst` | `Name verdeckt` | „Zuerst" ist zeitlich und nicht zeichenbar. „Verdeckt" ist ein durchgestrichenes Auge. |
| `Regeln ignoriert` | `Regeln` (aus) | Negation im Label erzwingt sonst ein Icon mit Verbotsschrägstrich. |

**③ Eine Icon-Familie, eine Strichstärke.** Material Symbols Rounded, Weight 400, Grade 0. Füllung ist die *einzige* variable Achse. In Flutter heisst das konsequent `Icons.x` (gefüllt) und `Icons.x_outlined` (Umriss) im Paar — nie ein von Haus aus gefülltes Glyph neben einem Umriss-Glyph, sonst wirkt die Leiste unruhig, obwohl jedes Icon für sich schlicht ist.

Weitere Vorgaben:

- Glyph 18–20 px in einem 28 pt hohen Chip, Tippfläche 44 pt
- Farbe **nie** als alleiniges Signal — Füllung und Label tragen die Information, Farbe verstärkt nur
- Keine Badges oder Punkte auf Icons; Zahlen stehen als Text daneben
- Der Pool-Chip bekommt statt eines Glyphs einen **Mini-Fortschrittsring**, der sich leert. Ein Ring, der weniger wird, braucht keine Erklärung — das ist das einzige Element der Leiste, das ohne Label auskommt.

**Prüfung:** Labels abdecken und einer Kollegin zeigen. Die Status-Chips müssen so bestehen. Dass die Modus-Chips ohne Label scheitern, ist erwartet und kein Mangel — deshalb behalten sie ihres.

```dart
const chipRepeat = ChipSpec(
  id: 'random.replacement',
  label: 'Wiederholung',
  iconOn:  Icons.repeat,
  iconOff: Icons.repeat_outlined,
  tier: ChipTier.mode,
  defaultOn: false,
);
```

### 6.6 Chip-Inventar

**Zufallsgenerator**

| Chip | Icon | Stufe | Default | Verhalten beim Tippen |
|---|---|---|---|---|
| `Wiederholung` | `repeat` | ① | aus | mit Zurücklegen; Pool bleibt erhalten |
| `17/24` | Fortschrittsring | ② | — | Poolübersicht + Reset (`restart_alt`) |
| `22/24` | `how_to_reg` | ② | alle da | Anwesenheitsgrid |
| `Name verdeckt` | `visibility_off` | ① | aus | Auflösemodus (F6.2) |
| `×3` | — (Ziffer als Glyph) | ③→① | ×1 | Stepper; ab ×2 immer sichtbar |
| `Pause 3` | `hourglass_empty` | ③ | 3 | Cooldown-Länge |
| `Fairness streng` | `balance` | ③ | α = 1 | nur sichtbar bei α ≠ 1 |

**Gruppen — Setup und Ergebnis teilen sich dieselbe Leiste**

| Chip | Icon | Stufe | Default | Verhalten beim Tippen |
|---|---|---|---|---|
| `gleichmässig` | `horizontal_distribute` | ① | an | Grössenverteilung umschalten |
| `Historie` | `history` | ① | an (ab F5.2) | neu würfeln mit/ohne Paarungshistorie |
| `Regeln` | `rule` | ① | an | Constraints für diese Einteilung aussetzen |
| `3 fix` | `push_pin` | ② | — | zu Schritt ④; lange drücken = alle lösen |
| `Rollen` | `badge` | ③ | aus | Rollenvergabe (F4.3) |

`horizontal_distribute` ist das Verteilen-Symbol aus Grafikprogrammen und zeigt buchstäblich gleichmässig gesetzte Balken — eines der wenigen Icons hier, das tatsächlich ohne Label funktioniert. `balance` bleibt deshalb für die Fairness reserviert; beide gleichzeitig als Waage zu zeichnen wäre verwechselbar.

**Lernmodus (bestehend)** — dieselbe Leiste trägt `Foto→Name` (`swap_horiz`) und die Schwierigkeit (`signal_cellular_alt`). Das ist der Hauptgrund, die Komponente früh zu bauen: sie zahlt auf drei Features ein, nicht auf zwei.

Übrige Icons ausserhalb der Leiste: Vergleichsmodus `undo`, Reset `restart_alt`, Würfeln `casino`, Präsentationsmodus `fullscreen`, Export `ios_share`.

### 6.7 Vergleichsmodus

Wenn ein Chip das Ergebnis neu berechnet, erscheint für etwa 10 Sekunden ein `↩ vorher`-Chip, der zur vorherigen Fassung zurückspringt. Beliebig hin- und herschaltbar.

Das ist die Antwort auf „testen": Man sieht den Unterschied, den `Historie` oder `gleichmässig` tatsächlich macht, statt ihn sich vorstellen zu müssen. Ohne diesen Rücksprung ist jedes Ausprobieren ein Verlust der bisherigen Einteilung — und damit etwas, das man im Unterricht nicht riskiert.

### 6.8 Präsentationsmodus

Am Beamer sehen die SuS die Leiste mit. Deshalb: **nach 3 Sekunden Inaktivität ausblenden**, bei Berührung des unteren Bildschirmrands wieder einblenden. Status-Chips wie `Pool 17/24` dürfen sichtbar bleiben — die sind für die Klasse eher interessant als störend.

### 6.9 Persistenz

Chip-Zustände gehören in eine schlichte Key-Value-Tabelle, **pro Klasse mit globalem Fallback**:

```
settings:  key TEXT PRIMARY KEY, value TEXT
// "random.replacement"            → globaler Default
// "random.replacement.class.3"    → Überschreibung für Klasse 3
```

Lehrpersonen behandeln Klassen unterschiedlich — in der einen zieht man ohne Zurücklegen, in der anderen ist der Generator ein Auflockerungsspiel. Der Aufwand für die Klassenebene ist minimal, das Nachrüsten später nicht.

---

## 7. Umsetzungsreihenfolge

Sortiert nach Abhängigkeit zuerst, Komplexität zweitens. Aufwand: **S** ≈ halber Abend, **M** ≈ ein bis zwei Abende, **L** ≈ mehrere.

### Stufe 0 — Fundament

*Blockiert alles Weitere. Erst hier fertig werden, bevor Features anfangen.*

| ID | Feature | Aufwand | Hängt ab von | Stand |
|---|---|---|---|---|
| F0.1 | Feature-Auswahl-Screen, persistenter Klassenkontext | M | Klassenverwaltung | ✅ |
| F0.2 | Drift-Migration: alle acht neuen Tabellen | S | — | ✅ |
| F0.3 | `SelectionRepository` + `SelectionEngine` (Pool-Query, Reset) | M | F0.2 | ✅ |
| F0.4 | `ModeChipBar` + Settings-Store (Key-Value, klassenweise) | M | F0.1 | ✅ |

**Bewusst schon jetzt:** `poolKey` in beiden Tabellen anlegen, auch wenn erst Stufe 6 damit arbeitet. Und `GroupSets`/`PairCounts`/`GroupConstraints` gleich in derselben Migration — Drift-Migrationen auf SQLite-WASM sind mühsam genug, dass man sie nicht ohne Not vervierfacht.

So gebaut: acht Tabellen in einer Migration, `Settings` (6.9) eingeschlossen.
Dazu vier getrennte Reset-Pfade — `resetProgress`, `resetDrawHistory`,
`resetAbsences`, `resetGroupHistory`. Vier statt einem, weil das Vergessen der
Quiz-Ergebnisse nicht auch vergessen darf, wer dieses Semester schon aufgerufen
wurde. `GroupConstraints` überlebt `resetGroupHistory`: „A und B nicht zusammen"
ist eine Entscheidung, keine Historie.

**F0.4 gehört ins Fundament, nicht in die Politur.** Ohne gemeinsame Komponente erfindet jedes Feature seine eigene Toggle-Platzierung, und die Regel aus 6.3 (Nicht-Default wird sichtbar) müsste an fünf Stellen einzeln nachgezogen werden. Als Widget mit deklarativer Chip-Registrierung kostet sie einen Abend; nachträglich über fertige Screens gelegt ist sie ein Refactoring. Sie verbessert ausserdem den bestehenden Lernmodus mit — Richtung und Schwierigkeit sind genau solche Chips.

### Stufe 1 — Zufallsgenerator, benutzbar

| ID | Feature | Aufwand | Hängt ab von | Stand |
|---|---|---|---|---|
| F1.1 | Ziehung mit Zurücklegen | S | F0.3 | ✅ |
| F1.2 | Ziehung ohne Zurücklegen, sessionübergreifend | S | F0.3 | ✅ |
| F1.3 | Reset + Poolzähler | S | F1.2 | ✅ |
| F1.4 | Ergebnisscreen (Foto + Name gross) | M | F1.2 | ✅ |
| F1.5 | Undo (letztes `DrawEvent` löschen) | S | F1.2 | ✅ |

Nach dieser Stufe ist das Kernversprechen erfüllt und im Unterricht einsetzbar.

**Gebaut, mit zwei Abweichungen.**

*Das Ergebnis ist kein eigener Screen*, sondern die obere Hälfte des
Zufallsscreens. „Nochmal" ist der häufigste Folgeschritt überhaupt; ihn über
eine Navigation laufen zu lassen, hiesse bei jedem zweiten Aufrufen ein
Bildschirmwechsel. Der Chip-Leiste kommt das ebenfalls zugute — sie bleibt beim
Ergebnis sichtbar, statt auf dem Screen darunter zurückzubleiben.

*F3.2 (Cooldown) ist vorgezogen*, weil er im Repository ohnehin anfiel und in
der Leiste nur einen Stufe-③-Chip kostet.

*F3.3 (Mehrfachziehung) wurde gebaut und wieder entfernt.* Die Prüfung aus 6.5
— einer Kollegin zeigen, ob der Chip ohne Erklärung verständlich ist — hat er
nicht bestanden; die Rückfrage lautete wörtlich „macht irgendwie keinen Sinn,
für was ist das?". Dazu kommt, dass er inhaltlich wenig trägt: ohne
`Wiederholung` liefert dreimal Antippen dieselben drei verschiedenen Personen,
der Chip kaufte also nur, sie gleichzeitig zu sehen. Echte Teams bildet ohnehin
die Gruppeneinteilung. `DrawSettings.count` und die Engine können es weiterhin,
die Leiste bietet es nicht an.

**Aufgefallen, und bewusst so belassen:** eine Ziehung mit eingeschalteter
`Wiederholung` wird protokolliert wie jede andere — schaltet man die
Wiederholung danach aus, gelten diese SuS als schon dran gewesen. Das ist die
wörtliche Lesart von 4.2 („der Modus steuert nur, ob `gezogen` den Pool
filtert"), kollidiert aber mit dem Versprechen aus 6.4, dass Umschalten kein
Risiko sei: wer zum Aufwärmen zwanzigmal mit Wiederholung zieht, findet danach
einen fast leeren Topf.

**Entschieden: so lassen.** Der Poolzähler macht den Zustand sichtbar, und eine
neue Runde ist ein Fingertipp. Die saubere Behebung wäre eine Spalte an
`DrawEvents`, die festhält, ob eine Ziehung den Topf verbraucht — also Schema 3
samt Migration. Das ist der Nutzen nicht wert, solange es im Unterricht nicht
tatsächlich stört. Falls doch, ist der Weg damit beschrieben.

### Stufe 2 — Gruppen, benutzbar

| ID | Feature | Aufwand | Hängt ab von |
|---|---|---|---|
| F2.1 | Partitionierung: Grösse / Anzahl / Bereich / gleichmässig ✅ | M | — (reine Logik) |
| F2.2 | Gruppen-Ergebnisscreen mit Foto-Karten ✅ | M | F2.1 |
| F2.3 | Neu würfeln (Vorbelegung bleibt erhalten) ✅ | S | F2.2 |
| F2.4 | Vorbelegung: Grössen mit Untergrenzen, eingefrorene Blöcke — Logik ✅, UI offen | S | F2.1 |
| F2.5 | Foto-Chips per Drag & Drop zwischen Gruppen *(vormals F4.2)* | M | F2.2 |
| F2.6 | Geführter Setup-Flow (5 Schritte, überspringbar) | M | F2.4, F2.5 |

F2.1 ist pure Dart-Logik ohne DB-Abhängigkeit — **ideal für Unit-Tests** und parallel zu Stufe 1 machbar. Die Randfälle (leere Gültigkeitsmenge, n < min, n = 0) hier sauber abdecken, sie kommen in Stufe 5 als Constraints-Randfälle wieder.

**F4.2 ist nach Stufe 2 vorgezogen und heisst neu F2.5.** Grund: Das Widget zum Ziehen eines Foto-Chips in eine Gruppenkarte ist im Setup (Vorbelegung, Schritt ④) und im Ergebnis (nachträgliches Umsortieren) exakt dasselbe. Zweimal bauen wäre Verschwendung; hinterher zusammenführen wäre ein Refactoring. Der Unterschied ist nur die Datenquelle: im Setup die Fotoleiste der noch freien SuS, im Ergebnis die andere Gruppe.

F2.4 ist überraschend klein, weil die Vorbelegung im Algorithmus nichts Neues ist — sie friert Blöcke ein, die die lokale Suche ohnehin schon kennt. Der Aufwand steckt fast vollständig in der Machbarkeitsprüfung aus 4.5 und in brauchbaren Fehlermeldungen.

### Stufe 3 — Unterrichtstauglich

| ID | Feature | Aufwand | Hängt ab von |
|---|---|---|---|
| F3.1 | Anwesenheit (Grid, Pool-Integration) ✅ | M | F0.3, wirkt auf F1.2 + F2.1 |
| F3.2 | Cooldown (letzte k gesperrt) | S | F1.1 |
| F3.3 | Mehrfachziehung (m auf einmal) | S | F1.2 |
| F3.4 | Präsentationsmodus (Querformat, grosse Typo) | M | F1.4, F2.2 |
| F3.5 | Chip-Autofade im Präsentationsmodus | S | F0.4, F3.4 |
| F3.6 | Vergleichsmodus `↩ vorher` nach Chip-Umschaltung | M | F0.4, F2.2 |

**F3.1 ist die wichtigste Einzelmassnahme der ganzen Liste.** Ohne Anwesenheit zieht der Generator Abwesende, das ist im Unterricht sofort peinlich, und der Pool wird durch sie unbrauchbar. Nur deshalb nicht in Stufe 1, weil sie erst Sinn ergibt, wenn ein Pool existiert.

### Stufe 4 — Persistenz & Komfort

| ID | Feature | Aufwand | Hängt ab von |
|---|---|---|---|
| F4.1 | Gruppen speichern / laden | M | F2.2, F0.2 |
| F4.3 | Rollenvergabe (Protokoll, Zeit, Präsentation) | S | F2.2 |
| F4.4 | Statistik-Screen (Ziehhäufigkeit) | M | F0.2 |
| F4.5 | Gespeicherte Einteilung als Vorbelegung laden | S | F4.1, F2.6 |

*(F4.2 ist nach Stufe 2 gewandert, siehe F2.5.)*

F4.1 ist Voraussetzung für die Paarungshistorie — ohne gespeicherte Einteilungen gibt es nichts zu erinnern. Deshalb vor Stufe 5. F4.5 ist danach fast geschenkt: `GroupMembers` einer gespeicherten Einteilung sind genau das Format, das die Vorbelegung erwartet.

### Stufe 5 — Fairness & Intelligenz

| ID | Feature | Aufwand | Hängt ab von |
|---|---|---|---|
| F5.1 | Gewichtete Ziehung (α-Parameter) | M | F4.4 |
| F5.2 | Paarungshistorie (`PairCounts` + Kostenfunktion) | M | F4.1 |
| F5.3 | Constraints together / apart | L | F5.2 |

Diese Stufe verändert nur *wie* gewürfelt wird, nicht *was* möglich ist — deshalb spät. F5.3 ist der einzige echte L-Brocken: Union-Find, Machbarkeitsprüfung, verständliche Fehlermeldungen bei unlösbaren Regelkombinationen. F5.2 vorher zu bauen zahlt sich aus, weil die lokale Suche dann schon steht und Constraints nur ein zusätzlicher Term in der Kostenfunktion sind.

### Stufe 6 — Politur & Export

| ID | Feature | Aufwand | Hängt ab von |
|---|---|---|---|
| F6.1 | Karussell-Animation vor dem Ergebnis | S | F1.4 |
| F6.2 | Foto-zuerst-Auflösemodus | S | F1.4 |
| F6.3 | Export als Bild / PDF | L | F2.2, F4.1 |
| F6.4 | Mehrere Pools pro Klasse (UI für `poolKey`) | M | F1.2 |

F6.3 ist auf **Flutter Web** aufwändiger als es klingt: `RepaintBoundary` → PNG → Blob-Download, oder das `pdf`-Package mit manuellem Layout. Fotos liegen als BLOBs vor, müssen also erst dekodiert werden. Einplanen, aber nicht unterschätzen.

### Abhängigkeitsgraph (Kern)

```
F0.1 ─┬─→ F0.4 ─┬─→ (Chips in allen Features)
      │         ├─→ F3.5
      │         └─→ F3.6
      │
F0.1 ─┼─→ F0.2 ──→ F0.3 ─┬─→ F1.1 ──→ F3.2
      │                  ├─→ F1.2 ─┬─→ F1.3
      │                  │         ├─→ F1.4 ─┬─→ F3.4
      │                  │         │         ├─→ F6.1
      │                  │         │         └─→ F6.2
      │                  │         ├─→ F1.5
      │                  │         ├─→ F3.3
      │                  │         └─→ F6.4
      │                  └─→ F3.1
      └─────────────────────→ F4.4 ──→ F5.1

F2.1 ─┬─→ F2.2 ─┬─→ F2.3
      │         ├─→ F2.5 ──┐
      │         ├─→ F4.1 ──┼──→ F5.2 ──→ F5.3
      │         ├─→ F4.3   │
      │         └─→ F6.3   │
      └─→ F2.4 ────────────┴──→ F2.6 ──→ F4.5
                                  ↑
                            F4.1 ─┘
```

Die beiden Stränge sind bis Stufe 3 unabhängig — Gruppenlogik (F2.1) lässt sich also schreiben und testen, während der Zufallsgenerator noch offen ist.

F2.6 ist der einzige Knoten mit zwei Voraussetzungen aus derselben Stufe (F2.4 für die Logik, F2.5 für die Interaktion). Wer den Wizard früh will, baut F2.4 und F2.5 parallel.

---

## 8. Offene Entscheidungen

| Frage | Vorschlag | Wann entscheiden |
|---|---|---|
| Default-α für Gewichtung | 1 (weich), in Einstellungen 0/1/2; gezählt pro `poolKey` (4.2) | F5.1 |
| Default-Cooldown k | 3, abschaltbar | F3.2 |
| Auto-Reset bei leerem Pool | Nachfragen, per Einstellung abschaltbar | F1.3 |
| Zerfall der Paarungshistorie | Erst ohne bauen, nachrüsten wenn nötig | nach F5.2 |
| Anwesenheit pro Tag oder pro Lektion | **Entschieden:** pro Tag, als `IntColumn` `20260816` (siehe 3.1) | ✅ |
| Löscht Undo das `DrawEvent` oder markiert es? | Löschen; das Log soll die Realität abbilden, nicht Fehltipper | F1.5 |
| Constraints klassenweit oder pro Einteilung? | Klassenweit, mit Schalter „für diese Einteilung ignorieren" | F5.3 |
| Vorbelegung sessionübergreifend speichern? | Nein — nur im aktuellen Setup. Wiederverwendung läuft über F4.5 | F2.4 |
| Vorbelegung vs. `apart`-Regel | Warnen, nicht blockieren (Vorrangregel 4.6) | F5.3 |
| Grössen bei Vorbelegung anpassen oder halten? | Anpassen (Untergrenzen), Fehler nur bei echter Unmöglichkeit | F2.4 |
| Chip-Zustände pro Klasse oder global? | Pro Klasse mit globalem Fallback (6.9) | F0.4 |
| Ab wie vielen Chips wird die Leiste unübersichtlich? | Ab 5 sichtbaren; darüber Stufe-③-Chips härter einklappen | nach F3.4 |
| Dauer des `↩ vorher`-Chips | 10 s, oder bis zur nächsten Aktion | F3.6 |
| Wirkt die Anwesenheit auch im Lernmodus? | **Entschieden:** nein — geübt wird ausserhalb der Lektion | ✅ |
| Was löscht „Fortschritt zurücksetzen"? | **Entschieden:** nur Leitner und Verwechslungen; Ziehungen, Anwesenheit und Gruppen haben eigene Reset-Pfade | ✅ |
| Was passiert mit SuS, die die Klasse verlassen? | **Entschieden:** `Students.active = false` statt löschen (3.1) | ✅ |
| Verbrauchen Ziehungen mit `Wiederholung` den Topf? | **Entschieden:** ja, so lassen — der Zähler zeigt es, eine neue Runde behebt es (Stufe 1) | ✅ |
| Automatik für den Präsentationsmodus | Nur bei kurzer Fensterseite < 600 dp; am Laptop ist immer Querformat | F3.4 |

---

## 9. Testfälle für die Partitionierung

Diese Fälle gehören als Unit-Tests direkt zu F2.1 — sie decken die Randbereiche ab, an denen solche Algorithmen typischerweise scheitern:

> **Abweichung in Zeile 2.** Bei n = 25 und fixer Grösse 4 nennt 4.3 im Fliesstext
> *beide* Ergebnisse zulässig: „5×5 oder 6 Gruppen à 4–5". Gebaut ist das
> zweite, weil es aus einer einzigen Regel folgt — `g = n div Grösse`, dann
> gleichmässig verteilen — die auch 24/4 → 6×4 und alle anderen Fälle trägt.
> Für 5×5 bräuchte es eine Sonderregel, die die Gruppenzahl senkt, bis die
> Grösse *über* der genannten liegt; das widerspricht „Gruppen von 4".

| n | Bereich / Grösse | gleichmässig | Erwartung |
|---|---|---|---|
| 24 | genau 4 | — | 6×4 |
| 25 | genau 4 | ja | 5×5 — **gebaut: 1×5 + 5×4** (siehe unten) |
| 25 | genau 4 | nein | 6×4 + 1×1 |
| 23 | 2–3 | ja | 5×3 + 4×2 (g\*=9) |
| 7 | 4–5 | ja | Fehler + Vorschlag |
| 1 | 2–3 | ja | Fehler, sinnvolle Meldung |
| 0 | beliebig | — | leere Einteilung, kein Absturz |
| 30 | 6 Gruppen | ja | 6×5 |
| 24 | 5 Gruppen | ja | 4×5 + 1×4 |

Und für die Vorbelegung (F2.4):

| n | g | Vorbelegung | Erwartung |
|---|---|---|---|
| 24 | 6 | 2 in G1 | 6×4, die 2 sitzen in G1 |
| 25 | 6 | 5 in G1 | G1 = 5 (voll), 5×4 |
| 25 | 6 | 5 in G1, 5 in G2 | Fehler: nur 1 Gruppe darf 5 sein |
| 24 | 6 | 5 in G1 | Fehler mit Vorschlag „5 Gruppen" |
| 24 | 6 | alle 24 verteilt | keine Zufallszuteilung, Ergebnis = Eingabe |
| 24 | 6 | 1 in G1, danach abwesend | Fixierung gelöst, Hinweis, 6×4 aus 23 → Fehler/Neuberechnung |
| 24 | 6 | A in G1 fix, A+B `together` | B landet zwingend in G1 |
| 24 | 6 | A in G1, B in G3, A+B `together` | Fehler: widersprüchlich |
| 24 | 6 | A+B beide in G1, A+B `apart` | Warnung, aber Einteilung erfolgt |
