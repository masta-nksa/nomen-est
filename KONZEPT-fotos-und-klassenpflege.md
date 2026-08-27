# Nomen est — Kapitel: Fotos und Klassenpflege

*Ergänzung zu [KONZEPT-nomen-est.md](KONZEPT-nomen-est.md)*

> **Stand:** Spezifikation, nichts davon gebaut. Löst die beiden ersten
> Einträge unter „Wünsche aus dem Gebrauch" ab (Fotos ersetzen, Personen ohne
> Foto) und macht aus ihnen einen zusammenhängenden Plan.

---

## 1. Warum — drei Probleme, die leicht verwechselt werden

Der Wunsch heisst „Fotos austauschen", aber dahinter stecken drei verschiedene
Probleme mit drei verschiedenen Quellen. Sie zu trennen ist die halbe
Entscheidung, denn **keine Quelle löst mehr als eines davon.**

| Problem | Woran es liegt | Was es allein löst |
|---|---|---|
| **Bestand** | Neuzuzüger/innen fehlen, Weggezogene stehen noch drin | Ein frischer Export aus der Schulverwaltung |
| **Qualität** | Die Bilder im PDF sind 200×200 px (gemessen, Abschnitt 2) | Die Einzelfotos, die klassenweise in besserer Qualität vorliegen |
| **Alterung** | Pro Klasse wird **einmal** fotografiert. Ein Kurs, der im 3. Jahr beginnt, arbeitet mit Bildern aus dem 1. Jahr | Nur ein selbst aufgenommenes Bild |

Die dritte Zeile ist die unbequeme. **Ein frischer Export bringt dasselbe alte
Foto mit** — es wurde ja nie ein neues gemacht, der Export exportiert es bloss
erneut. Der Merge-Import aus einem neuen PDF löst also ausschliesslich das
Bestandsproblem, nicht das, was im Unterricht am meisten stört: dass jemand mit
sechzehn auf dem Bild aus dem 1. Jahr kaum wiederzuerkennen ist.

Daraus folgt die Reihenfolge in Abschnitt 8, und sie ist eine andere als die,
die man beim Stichwort „Fotos austauschen" zuerst vermutet.

## 2. Was gemessen wurde — die Auflösung ist gedeckelt

Die vier Klassen-PDFs in `pdfs/` enthalten ihre Porträts als eingebettete
JPEGs:

| PDF | Bilder | Format |
|---|---|---|
| `F2025D.pdf` | 21× | 200×200, DCTDecode |
| | 3× / 1× | 149×200 / 148×200 |
| `f2026A.pdf` | 26× | 200×200 |
| `g2025a.pdf` | 22× / 2× | 200×200 / 149×200 |
| `g2026h.pdf` | 21× | 200×200 |

Der Parser rendert die Seite mit `_renderDpi = 200` und schneidet Kästchen von
rund 213 px Höhe aus — er holt damit **praktisch genau das heraus, was drin
ist**, mit einem Hauch Hochskalierung. Die naheliegende Idee, die Qualität
durch eine höhere Render-Auflösung zu heben, bringt deshalb nichts: im PDF
liegen keine weiteren Daten. Der Deckel sitzt in der Quelle.

Merke, damit das nicht ein zweites Mal untersucht wird: **200×200 ist alles,
was ein Klassenfoto-PDF hergibt.** Jede bessere Quelle ist strikt besser, und
an der App ist dafür nichts zu optimieren.

## 3. Drei Wege hinein

### 3.1 Ein Foto ersetzen — Kamera oder Mediathek

Der direkte Weg, und der einzige gegen die Alterung. In der Galerie ein
Gesicht antippen → „Foto ersetzen" → Bild wählen → zuschneiden → fertig.

Deckt den häufigsten Einzelfall ab („dieses eine Bild geht gar nicht") und ist
das Fundament für 3.2, weil beide dieselbe Bildaufbereitung brauchen
(Abschnitt 5).

### 3.2 Die Einzelfotos einer Klasse auf einmal

Die Sammlung liegt klassenweise vor und ist besser als das PDF. Als
Mehrfachauswahl von Bilddateien oder als ZIP — `file_picker` und `archive`
sind beide schon Abhängigkeiten, es braucht dafür kein neues Paket.

Zuordnung über den Dateinamen zur Person. Wie die Dateien tatsächlich heissen,
ist offen (Abschnitt 7) — davon hängt ab, ob das ein exakter Abgleich wird oder
eine Heuristik mit Review.

Das ist der grösste Hebel gegen das Qualitätsproblem: eine ganze Klasse in
einem Vorgang, ohne PDF-Parsing und ohne Namensheuristik auf gerenderten
Pixeln.

### 3.3 Merge-Import eines frischen PDF-Exports

Derselbe Parser, neues Ziel: statt „neue Klasse anlegen" ein Eintrag **„Aus PDF
aktualisieren …"** im Klassenmenü, neben Umbenennen / Exportieren /
Zurücksetzen ([classes_screen.dart:106](lib/screens/classes_screen.dart:106)).

Drei Fälle pro Person:

| Fall | Vorschlag |
|---|---|
| Im PDF, nicht in der Klasse | Neu anlegen |
| In beiden | Foto aktualisieren, Name unverändert lassen |
| In der Klasse, nicht im PDF | `active = false` — hat die Klasse verlassen |

Der dritte Fall steht bewusst dabei, obwohl er im Wunsch nicht vorkam: er ist
die andere Hälfte der Bestandspflege, und die Spalte dafür existiert bereits.

**Die Quelle ist der echte Export, nicht eine Vorlage zum Befüllen.** Ein
frischer Export hat das Layout, das der Parser versteht. Eine von Hand
zusammengebaute Vorlage müsste dieses Layout exakt treffen, und wie eng die
Toleranz ist, steht in den Bugs 7 und 8 des Hauptkonzepts: ein Foto, das 18 px
schmaler war und 19 px neben seiner Spalte sass, hat einer ganzen Seite die
Vornamen gekostet. Das ist nichts, was man jemandem zumutet, der zwischen zwei
Lektionen ein Dokument zusammenschiebt — zumal eine solche Vorlage nach
Abschnitt 1 ohnehin nur Bestand und Qualität brächte, und für beides sind 3.2
und 3.3 der bessere Weg.

## 4. Was alle drei Wege sicher macht

Vier Regeln, von denen drei nicht offensichtlich sind.

**Identität überlebt.** Ein Foto-Update ist ein `UPDATE students SET jpegBytes`
auf **derselben `id`** — nie löschen und neu anlegen. An `studentId` hängen
`Progress`, `Confusions`, `DrawEvents`, `GroupMembers` und `PairCounts`. Ein
Löschen cascadiert durch und schreibt eine Geschichte um, die stattgefunden
hat. Dieselbe Begründung steht bereits beim `active`-Flag in
[database.dart:39](lib/data/database.dart:39). Der Lernfortschritt einer Klasse
ist das Wertvollste in der Datenbank; ein neues Bild darf ihn nicht anfassen.

**Kein stilles Zuordnen.** Der Abgleich läuft über Namen oder Dateinamen, und
beide sind unzuverlässig — der Parser trennt Vor- und Nachname heuristisch
(Hauptkonzept 3.4), Doppelnamen und Umlaute driften. Zwei Fehlerarten, beide
schlecht, aber ungleich:

- **Falscher Treffer** — überschreibt still das falsche Gesicht. Die Klasse übt
  danach einen falschen Namen ein, und niemand merkt es.
- **Verpasste Zuordnung** — legt ein Duplikat an. Hässlich, aber sichtbar.

Weil der erste Fall unsichtbar scheitert, gilt: **Review-Screen mit
Vorschlägen**, nach dem Muster von `_ReviewList`
([import_screen.dart:209](lib/screens/import_screen.dart:209)), jede Zeile als
*aktualisieren / neu anlegen / überspringen*. Eine Bestätigung pro Person klingt
nach Arbeit, fällt aber einmal pro Kurs an, nicht pro Lektion.

**Wer fehlt, wird stillgelegt, nicht gelöscht** — und auch das nur als
Vorschlag im Review. Ein PDF, dem eine Seite fehlt oder bei dem der Parser
gestolpert ist, würde sonst die halbe Klasse deaktivieren.

**`orderIndex` bleibt.** Neue Personen hinten anhängen, bestehende Reihenfolge
unangetastet. `chunksOf` arbeitet in Klassenreihenfolge, und der Kommentar dort
verspricht ausdrücklich, dass ein Kapitel zwischen Sitzungen dasselbe Kapitel
bleibt — eine Neusortierung würde jede manuelle Einteilung still verschieben.
Preis: die Galerie ist danach nicht mehr alphabetisch. Falls das stört, wäre
„Reihenfolge neu übernehmen" eine eigene, ausdrückliche Aktion.

## 5. Bildaufbereitung

Betrifft 3.1 und 3.2 gemeinsam und ist der einzige Teil, der echte Arbeit ist.

Ein Bild aus der Mediathek hat beliebiges Seitenverhältnis und gern 4 MB. Ohne
Aufbereitung gibt das weisse Balken am Beamer (Bug 8) und eine aufgeblähte
IndexedDB.

- **Zuschnitt auf ein festes Seitenverhältnis**, damit die Karten in Galerie,
  Quiz und Beamer gleich hoch bleiben. Welches — offen (Abschnitt 7).
- **Verkleinern mit Obergrenze, nicht auf PDF-Mass.** Auf 200×200
  herunterzurechnen würde genau das wegwerfen, wofür der ganze Aufwand
  betrieben wird. Ein Vorschlag: längste Kante 600 px, JPEG-Qualität ~85. Bei
  26 Personen sind das grob 1–2 MB pro Klasse.
- **Gemischte Auflösungen sind in Ordnung.** Eine Klasse darf alte PDF-Bilder
  und neue Fotos nebeneinander enthalten; die Screens skalieren ohnehin. Was
  nicht gemischt sein darf, ist das Seitenverhältnis.
- **Der Bildausschnitt wird von Hand gesetzt.** Auf einem Handyfoto sitzt das
  Gesicht irgendwo. Automatische Gesichtserkennung fällt aus: sie wäre ein
  eigenes Paket, sie liefe über Bilder von Jugendlichen, und sie scheitert
  unauffällig. Stattdessen ein Rahmen zum Schieben und Zoomen —
  `photo_zoom.dart` kann Pan und Zoom bereits und ist zum Teil wiederverwendbar.
- **`image` ist schon Abhängigkeit**, Zuschnitt und Neukodierung brauchen kein
  neues Paket. Offen ist nur der Aufnahmeweg (Abschnitt 7).

## 6. Was sich an Code und Schema ändert

| Was | Migration? |
|---|---|
| Foto ersetzen, Sammel-Import, Merge-Import | **Nein.** `UPDATE students SET jpegBytes`, `INSERT`, `active = false` — alles auf dem bestehenden Schema |
| Person ohne Foto aufnehmen | **Ja** — `jpegBytes` ist heute Pflicht-`blob()` und müsste `nullable()` werden. Dann trägt jeder Screen, der ein Bild zeichnet, einen Platzhalterfall |

Für die Migration gilt der teuer bezahlte Merksatz aus Bug 5: **wiederholbar
machen**, an `pragma_table_info` geknüpft und nicht an die Versionsnummer, und
Indizes als explizites SQL.

**Der Merge-Import löst „Person ohne Foto" nicht.** Der Parser ist
fotogetrieben — er findet erst eine `PhotoBox` und sucht dann darunter nach dem
Namen. Wer im Export kein Bild hat, existiert für ihn nicht. Das sind
ausgerechnet die Neuzuzüger/innen, um die es beim Wunsch ging. Es braucht
deshalb weiterhin einen Weg „Person von Hand hinzufügen" **und** die
Schemaänderung; der Merge-Import ersetzt beides nicht.

## 7. Offene Punkte

Nichts davon blockiert 3.1. Der Rest wartet auf Antworten.

| # | Frage | Was daran hängt |
|---|---|---|
| O1 | **Wie heissen die Einzelfoto-Dateien?** `Nachname_Vorname.jpg`, eine Schülernummer, etwas anderes? | Ob 3.2 ein exakter Abgleich wird oder eine Heuristik mit Review |
| O2 | **Gibt es eine stabile Kennung aus der Schulverwaltung** (Schüler-/Personennummer) — im PDF, im Dateinamen, irgendwo? | Wäre ein besserer Schlüssel als der Name für 3.2 *und* 3.3. Müsste dann als Spalte mitgeführt werden (Migration) |
| O3 | **In welcher Form liegt die Sammlung vor?** Ordner, ZIP, Netzlaufwerk, einzeln herunterzuladen? | Ob Mehrfachauswahl reicht oder ZIP-Entpacken dazukommt; auf dem iPad ist das ein Unterschied |
| O4 | **Welches Seitenverhältnis** bekommen zugeschnittene Fotos? Das der PDF-Kästchen, oder ein Porträtformat wie 3:4? | Abschnitt 5; einmal entschieden, gilt es für alle drei Wege |
| O5 | **Direkt mit der Kamera aufnehmen, oder nur aus der Mediathek wählen?** `file_picker` öffnet die Dateiauswahl; für „Kamera jetzt" bräuchte es vermutlich `image_picker` | Ein Paket mehr oder nicht |
| O6 | **Fotos von Jugendlichen selbst aufnehmen** ist eine Frage über die App hinaus (Einwilligung, Aufbewahrung, wer entscheidet). Die App speichert wie bisher ausschliesslich lokal | Ob 3.1 die Kamera überhaupt anbietet oder nur vorhandene Bilder |
| O7 | **Soll sichtbar sein, welches Foto noch das alte aus dem PDF ist?** Etwa `photoSource` / `photoUpdatedAt` als Spalte | Kleine Migration; hilft beim Nachführen einer Klasse über zwei Jahre |
| O8 | **Was passiert mit dem Lernfortschritt, wenn ein Gesicht ausgetauscht wird?** Vorschlag: nichts — es ist dieselbe Person, und der Name ist das Lernziel | Ob es eine Rückfrage braucht |
| O9 | **Darf der Merge-Import auch Namen korrigieren**, oder nur Fotos und Bestand? | Namensänderungen sind selten, aber eine stille Umbenennung wäre schwer nachzuvollziehen |
| O10 | **Ein Kollegium ist keine Klasse.** Die AME arbeitet mit demselben Schulnetz und hat dieselben Klassenfoto-PDFs — für Schülerinnen und Schüler ist der Import dort also kein Sonderfall. Wer aber die *Lehrpersonen* lernen will (eine neue Schulleitung, eine neue Lehrperson), findet keine Quelle: für ein Kollegium erzeugt die Schulverwaltung kein Foto-PDF | Der erste Gebrauch ausserhalb des Unterrichts, und er fällt neben den PDF-Import. Es bliebe 3.2 (Einzelfotos, sofern es sie gibt) und P6 (Person von Hand) — womit P6 nicht mehr nur Nachzügler ist. Offen ist zudem, ob eine Gruppe ohne Klasse „Klasse" heissen soll, oder ob das Modell einen neutraleren Begriff braucht |

## 8. Umsetzungsreihenfolge

Nach Abschnitt 1 sortiert, nicht nach Aufwand: das dringendste Problem im
Unterricht ist die Alterung, und die löst nur 3.1.

| ID | Schritt | Aufwand | Hängt an |
|---|---|---|---|
| P1 | Bildaufbereitung als reine Funktion: Zuschnitt auf Seitenverhältnis, Verkleinern, JPEG-Kodierung | S | O4 |
| P2 | Zuschnitt-Oberfläche (Rahmen, schieben, zoomen) | M | P1, `photo_zoom.dart` |
| P3 | „Foto ersetzen" in der Galerie | S | P1, P2, O5 |
| P4 | Sammel-Import der Einzelfotos, mit Review | M | P1, O1, O3 |
| P5 | Merge-Import aus PDF: Abgleich, Review, `active`-Pflege | M | O2, O9 |
| P6 | Person von Hand hinzufügen — `jpegBytes` nullable, Platzhalter in allen Screens | M | Migration |

P1 trägt die Fachlichkeit und ist ohne Datenbank und ohne UI testbar —
dieselbe Aufteilung wie bei der Partitionierung und beim adaptiven Lernen.

P3 allein ist schon nützlich und braucht von den offenen Punkten nur O4 und O5.

## 9. Testfälle

Bildaufbereitung (P1), reine Logik:

| Eingabe | Erwartung |
|---|---|
| Querformat 4000×3000 | Zugeschnitten auf das Zielverhältnis, längste Kante ≤ Obergrenze |
| Hochformat, sehr schmal | Zugeschnitten ohne Verzerrung, kein Rand |
| Bild kleiner als die Obergrenze | Nicht hochskaliert |
| Bereits im Zielverhältnis | Nur neu kodiert |
| Kaputte Datei | Sichtbarer Fehler, kein stiller Ausfall (Bug 6) |

Abgleich (P4/P5), reine Logik:

| Ausgangslage | Erwartung |
|---|---|
| Alle Namen decken sich | Alle als „aktualisieren" vorgeschlagen |
| Eine Person nur in der Quelle | „neu anlegen" |
| Eine Person nur in der Klasse | „stilllegen" |
| Zwei gleiche Nachnamen in der Klasse | Keine Zuordnung ohne Vornamen, keine willkürliche Wahl |
| Umlaut-Variante (`Mueller` / `Müller`) | Als Treffer vorgeschlagen, aber im Review sichtbar |
| Quelle enthält niemanden aus der Klasse | Warnung statt 26× „neu anlegen" |

Datenbank:

| Ausgangslage | Erwartung |
|---|---|
| Foto ersetzen bei einer Person mit Fortschritt | `id`, `Progress`, `Confusions` unverändert, nur `jpegBytes` neu |
| Person stilllegen, die in `DrawEvents` vorkommt | Zeilen bleiben, Person fällt aus Topf und Quiz |
| Merge auf einer Klasse mit manueller Kapitel-Einteilung | `orderIndex` der Bestehenden unverändert, Neue hinten |
