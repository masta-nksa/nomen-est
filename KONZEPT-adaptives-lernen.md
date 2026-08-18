# Nomen est — Kapitel: Adaptives Lernen

*Ergänzung zu [KONZEPT-nomen-est.md](KONZEPT-nomen-est.md)*

> **Stand:** Spezifikation, nichts davon gebaut. Der heutige automatische
> Umfang (`automaticScope` in `lib/quiz/chunks.dart`) ist die Vorstufe, die
> dieses Kapitel ersetzt.

---

## 1. Warum

Der automatische Umfang wählt heute *vor* der Runde aus, wer geübt wird: alle
bereits Gelernten plus die nächsten fünf Unbekannten. Innerhalb der Runde
ändert sich daran nichts. Das hat drei Folgen, die sich im Gebrauch zeigen:

**Der Zufluss kommt in Sprüngen.** Bei 15 Karten auf fünf Gesichter wird jede
Person etwa dreimal abgefragt. Wer alles richtig hat, schiebt damit alle fünf
über die Schwelle — und die nächste Runde umfasst nicht sechs Personen,
sondern zehn. Die Treppe, die gemeint war, ist ein Sprung.

**Wer sitzt, bleibt im Weg.** Gelernte verlassen die Runde nie. Die Gewichtung
drückt sie zwar nach hinten (Box 1 wiegt 25-mal so viel wie Box 5), aber sie
belegen weiter Karten, die den Unbekannten fehlen.

**Nichts kommt zurück.** Ein Name, der einmal die Schwelle erreicht hat, wird
nie wieder gezielt geprüft. Drei Wochen später ist er weg, und die App merkt
es nicht.

## 2. Modell

Zwei Mengen und eine Kapazität, die sich am Erfolg orientiert.

| | |
|---|---|
| **Aktiv** | Wer gerade gedrillt wird. Klein, wächst und schrumpft während der Runde |
| **Reserve** | Alle übrigen der Klasse: noch nie gesehen, oder im Ruhestand |
| **Kapazität** | Wie gross *aktiv* sein darf. Steigt mit einer Serie richtiger Antworten, fällt bei einem Fehler |
| **Serie** | Richtige Antworten in Folge, seit dem letzten Fehler |

Der entscheidende Unterschied zu heute: **Zu- und Abfluss geschehen innerhalb
der Runde.** Wer die Ruhestandsgrenze erreicht, verlässt *aktiv* sofort, und
aus der Reserve rückt die fälligste Person nach — nicht erst beim nächsten
Rundenstart.

Damit reguliert sich die Schwierigkeit selbst: Wer läuft, bekommt mehr
Gesichter gleichzeitig; wer stolpert, bekommt weniger. Das ist dieselbe Idee
wie beim Leitner-System, nur eine Ebene höher — dort steuert der Erfolg die
*Häufigkeit*, hier zusätzlich die *Breite*.

## 3. Regeln

```
Rundenstart:
    kapazität ← startKapazität
    serie     ← 0
    aktiv     ← die kapazität fälligsten der Klasse
    reserve   ← alle übrigen

Nach jeder Antwort (nur der erste Versuch zählt, wie bisher):

    richtig:
        Box hoch (bestehende Leitner-Regel)
        serie++
        wenn Box >= ruhestandBox:
            aus aktiv entfernen          # Abfluss, sofort
        wenn serie mod serieProSchritt = 0 und kapazität < maxKapazität:
            kapazität++                  # die Gruppe darf wachsen

    falsch:
        Box runter (bestehende Regel)
        serie ← 0
        wenn kapazität > minKapazität:
            kapazität--
            wenn |aktiv| > kapazität:
                die Person mit der höchsten Box in den Ruhestand
                # nicht die schwächste — die ist der Grund, warum man übt

    auffüllen:
        solange |aktiv| < kapazität und reserve nicht leer:
            fälligste Person aus der reserve nach aktiv
```

### Fälligkeit

Die Reihenfolge, in der aus der Reserve nachgerückt wird:

1. **Überfällige Wiederholungen** — Box >= ruhestandBox und `lastSeenAt` älter
   als das Intervall der Box
2. **Noch nie gesehen** (Box 1, `lastSeenAt` null), in Klassenreihenfolge
3. **Alle übrigen**, am längsten nicht gesehen zuerst

Überfällige vor Neuen, weil ein vergessener Name teurer ist als ein
verzögerter neuer. Am Anfang ist ohnehin nichts überfällig, dort fliessen also
die Unbekannten.

Intervalle nach Box, klassisch: **Box 3 → 1 Tag, Box 4 → 3 Tage, Box 5 → 7
Tage.** `Progress.lastSeenAt` gibt es bereits — **keine Migration nötig.**

## 4. Parameter

Startwerte als Vorschlag; alle als benannte Konstanten, damit man sie im
Gebrauch nachzieht.

| Name | Vorschlag | Begründung |
|---|---|---|
| `startKapazität` | 3 | Drei Gesichter kann man beim ersten Kontakt auseinanderhalten, fünf schon knapp |
| `minKapazität` | 3 | Darunter wird die Auswahl zur Ja/Nein-Frage |
| `maxKapazität` | 9 | Mehr Gesichter gleichzeitig hält kaum jemand |
| `serieProSchritt` | 3 | Drei richtige in Folge sind ein Beleg, eine ist Zufall |
| `ruhestandBox` | 4 | Dreimal richtig. Bei 5 dauert eine erste Runde zu lange |

## 5. Was sich am Code ändert

**`QuizEngine` bekommt die Reserve dazu** und darf ihren Kandidatensatz
verändern. Heute ist er beim Konstruieren fix. Neu: aufnehmen, in Ruhestand
schicken, Kapazität und Serie führen. Der Auswahl- und Ablenkeralgorithmus
bleibt, er arbeitet weiterhin auf *aktiv*.

**`automaticScope` entfällt.** Es wählt heute die Startmenge; das übernimmt die
Fälligkeitsordnung. `chunksOf`, `upToChunk` und `QuizScope.manual` bleiben
unberührt — die manuelle Einteilung ist eine andere Frage und weiterhin
sinnvoll.

**`scopeFor` liefert für `automatic` nur noch die Startmenge**, den Rest regelt
die Engine.

**Der Setup-Screen** sagt heute „5 von 26 im Spiel — 0 sitzen, 5 werden gerade
gelernt". Neu wäre etwas wie „startet mit 3 und wächst mit" plus, falls
vorhanden, „4 Wiederholungen fällig".

**Der Quiz-Screen** könnte die aktuelle Gruppengrösse zeigen. Offen, ob das
hilft oder ablenkt.

## 6. Randfälle

| Fall | Verhalten |
|---|---|
| Klasse kleiner als `startKapazität` | Aktiv = ganze Klasse, Reserve leer, Kapazität irrelevant |
| Alle im Ruhestand, nichts fällig | Die am längsten nicht gesehene Person zurückholen — die Runde darf nie leerlaufen |
| Reserve leer, Kapazität wächst | Aktiv bleibt wie es ist, kein Fehler |
| Kapazität fällt unter die Grösse von aktiv | Höchste Box geht, nicht die niedrigste |
| Abwesenheit | Spielt im Lernmodus keine Rolle (Entscheid aus dem Zufallskapitel) |

## 7. Testfälle

Die Engine ist reine Logik und lässt sich ohne Datenbank prüfen.

| Ausgangslage | Erwartung |
|---|---|
| Rundenstart, nichts gelernt | Aktiv = 3, alle Box 1 |
| 3× richtig in Folge | Kapazität 4, eine Person rückt nach |
| Person erreicht die Ruhestandsbox | Verlässt aktiv sofort, Ersatz rückt in derselben Runde nach |
| Fehler nach langer Serie | Serie 0, Kapazität −1, höchste Box geht |
| Fehler bei Kapazität 3 | Kapazität bleibt 3, niemand geht |
| Reserve leer, jemand geht in Ruhestand | Aktiv schrumpft, kein Absturz |
| Klasse mit 2 Personen | Läuft, Kapazität wird nie relevant |
| Überfällige Person, daneben Unbekannte | Die Überfällige rückt zuerst nach |
| Nichts überfällig | Unbekannte rücken in Klassenreihenfolge nach |

## 8. Offene Entscheidungen

| Frage | Vorschlag |
|---|---|
| Kapazität über Runden hinweg behalten? | Nein — jede Runde beginnt bei `startKapazität`. Das gibt ein Aufwärmen und braucht keinen gespeicherten Zustand |
| Serie über Runden hinweg? | Nein, aus demselben Grund |
| Ruhestand ab Box 4 oder 5? | 4 zum Start, im Gebrauch nachziehen |
| Zeigt der Quiz-Screen die Gruppengrösse? | Erst ohne bauen; es könnte mehr ablenken als helfen |
| Was passiert am Rundenende mit halb Gelernten? | Nichts Besonderes — die Boxen tragen den Stand ohnehin |
| Gilt das Modell auch für „Name → Foto"? | Ja, es betrifft die Auswahl, nicht die Darstellung |

## 9. Umsetzungsreihenfolge

| ID | Schritt | Aufwand |
|---|---|---|
| A1 | Fälligkeitsordnung als reine Funktion, mit Intervallen nach Box | S |
| A2 | `QuizEngine` mit veränderlichem Aktivsatz, Kapazität und Serie | M |
| A3 | Einbinden in den Quiz-Screen, `automaticScope` ablösen | S |
| A4 | Texte im Setup-Screen | S |
| A5 | Parameter im Gebrauch nachziehen | — |

A1 und A2 sind ohne Datenbank und ohne UI testbar und tragen die ganze
Fachlichkeit — dieselbe Aufteilung, die bei der Partitionierung der
Gruppeneinteilung gut funktioniert hat.
