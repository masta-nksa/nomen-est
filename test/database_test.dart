import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> seedSet({String label = 'Testklasse', int count = 3}) => db.createPhotoSet(
        label: label,
        sourceFile: 'test.pdf',
        people: [
          for (var i = 0; i < count; i++)
            (
              displayName: 'Nachname$i Vorname$i',
              firstName: 'Vorname$i',
              lastName: 'Nachname$i',
              jpegBytes: Uint8List.fromList([i, i, i]),
            ),
        ],
      );

  test('creating a set gives every person a progress row in box 1', () async {
    final setId = await seedSet();
    final people = await db.personsInSet(setId);
    final progress = await db.progressForSet(setId);

    expect(people, hasLength(3));
    expect(progress, hasLength(3));
    expect(progress.every((p) => p.box == 1), isTrue);
    expect(people.map((p) => p.orderIndex), [0, 1, 2]);
  });

  test('deleting a set removes its people and their progress', () async {
    final setId = await seedSet();
    await db.deletePhotoSet(setId);

    expect(await db.personsInSet(setId), isEmpty);
    expect(await db.progressForSet(setId), isEmpty);
  });

  test('deleting one set leaves the others untouched', () async {
    final keep = await seedSet(label: 'Bleibt');
    final remove = await seedSet(label: 'Weg');
    await db.deletePhotoSet(remove);

    expect(await db.personsInSet(keep), hasLength(3));
    expect(await db.personsInSet(remove), isEmpty);
  });

  group('recordAnswer', () {
    test('a correct answer moves up a box and counts the streak', () async {
      final setId = await seedSet();
      final person = (await db.personsInSet(setId)).first;

      await db.recordAnswer(personId: person.id, correct: true, elapsedMs: 1000);
      var progress = (await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id);
      expect(progress.box, 2);
      expect(progress.correct, 1);
      expect(progress.streak, 1);
      expect(progress.avgMs, 1000);

      await db.recordAnswer(personId: person.id, correct: true, elapsedMs: 3000);
      progress = (await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id);
      expect(progress.box, 3);
      expect(progress.streak, 2);
      expect(progress.avgMs, 2000, reason: 'running average over both answers');
    });

    test('a wrong answer drops two boxes and resets the streak', () async {
      final setId = await seedSet();
      final person = (await db.personsInSet(setId)).first;

      for (var i = 0; i < 4; i++) {
        await db.recordAnswer(personId: person.id, correct: true, elapsedMs: 500);
      }
      expect((await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id).box, 5);

      await db.recordAnswer(personId: person.id, correct: false, elapsedMs: 500);
      final progress = (await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id);
      expect(progress.box, 3);
      expect(progress.streak, 0);
      expect(progress.wrong, 1);
    });

    test('boxes stay within 1..5', () async {
      final setId = await seedSet();
      final person = (await db.personsInSet(setId)).first;

      for (var i = 0; i < 10; i++) {
        await db.recordAnswer(personId: person.id, correct: true, elapsedMs: 500);
      }
      expect((await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id).box, 5);

      for (var i = 0; i < 10; i++) {
        await db.recordAnswer(personId: person.id, correct: false, elapsedMs: 500);
      }
      expect((await db.progressForSet(setId)).firstWhere((p) => p.personId == person.id).box, 1);
    });
  });

  group('recordConfusion', () {
    test('counts up on repeat confusions of the same pair', () async {
      final setId = await seedSet();
      final people = await db.personsInSet(setId);

      await db.recordConfusion(personId: people[0].id, confusedWithId: people[1].id);
      await db.recordConfusion(personId: people[0].id, confusedWithId: people[1].id);
      await db.recordConfusion(personId: people[0].id, confusedWithId: people[2].id);

      final confusions = await db.confusionsFor(people[0].id);
      expect(confusions, hasLength(2));
      expect(confusions.first.confusedWithId, people[1].id, reason: 'sorted by count');
      expect(confusions.first.count, 2);
    });

    test('confusions are directional', () async {
      final setId = await seedSet();
      final people = await db.personsInSet(setId);

      await db.recordConfusion(personId: people[0].id, confusedWithId: people[1].id);

      expect(await db.confusionsFor(people[0].id), hasLength(1));
      expect(await db.confusionsFor(people[1].id), isEmpty);
    });
  });

  test('resetProgress clears boxes and confusions but keeps the people', () async {
    final setId = await seedSet();
    final people = await db.personsInSet(setId);
    await db.recordAnswer(personId: people[0].id, correct: true, elapsedMs: 500);
    await db.recordConfusion(personId: people[0].id, confusedWithId: people[1].id);

    await db.resetProgress(setId);

    expect(await db.personsInSet(setId), hasLength(3));
    expect((await db.progressForSet(setId)).every((p) => p.box == 1 && p.correct == 0), isTrue);
    expect(await db.confusionsFor(people[0].id), isEmpty);
  });

  test('renaming a set keeps its people', () async {
    final setId = await seedSet(label: 'Alt');
    await db.renamePhotoSet(setId, 'Neu');

    final sets = await db.watchPhotoSets().first;
    expect(sets.single.label, 'Neu');
    expect(await db.personsInSet(setId), hasLength(3));
  });
}
