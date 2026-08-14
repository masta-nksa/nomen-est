import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nomen_est/quiz/quiz_engine.dart';
import 'package:nomen_est/quiz/quiz_settings.dart';

void main() {
  QuizEngine engineWith(
    List<CandidateStats> candidates, {
    QuizSettings settings = const QuizSettings(),
  }) =>
      QuizEngine(candidates: candidates, settings: settings, random: Random(42));

  List<CandidateStats> plainCandidates(int count) => [
        for (var i = 1; i <= count; i++) CandidateStats(personId: i, box: 1, wrong: 0),
      ];

  group('question building', () {
    test('the asked person is always among the options', () {
      final engine = engineWith(plainCandidates(10));
      for (var i = 0; i < 30; i++) {
        final question = engine.next()!;
        expect(question.optionIds, contains(question.personId));
      }
    });

    test('offers as many options as configured', () {
      final engine = engineWith(plainCandidates(10), settings: const QuizSettings(optionCount: 5));
      expect(engine.next()!.optionIds, hasLength(5));
    });

    test('never offers duplicate options', () {
      final engine = engineWith(plainCandidates(10), settings: const QuizSettings(optionCount: 8));
      for (var i = 0; i < 20; i++) {
        final options = engine.next()!.optionIds;
        expect(options.toSet(), hasLength(options.length));
      }
    });

    test('caps options at the number of people in a small class', () {
      final engine = engineWith(plainCandidates(3), settings: const QuizSettings(optionCount: 8));
      expect(engine.next()!.optionIds, hasLength(3));
    });

    test('returns null when there is nobody to compare against', () {
      expect(engineWith(plainCandidates(1)).next(), isNull);
      expect(engineWith(plainCandidates(0)).next(), isNull);
    });
  });

  group('confusion-based distractors', () {
    test('prefers the people actually confused with the target', () {
      final engine = engineWith(
        [
          const CandidateStats(personId: 1, box: 1, wrong: 0, confusedWith: {7: 5, 8: 4}),
          for (var i = 2; i <= 20; i++) CandidateStats(personId: i, box: 1, wrong: 0),
        ],
        settings: const QuizSettings(optionCount: 3, distractors: DistractorStrategy.confusion),
      );

      // Ask until person 1 comes up, then check who they are pitted against.
      for (var i = 0; i < 100; i++) {
        final question = engine.next()!;
        if (question.personId == 1) {
          expect(question.optionIds, containsAll([1, 7, 8]));
          return;
        }
      }
      fail('person 1 was never asked about');
    });

    test('falls back to random names when nothing has been confused yet', () {
      final engine = engineWith(
        plainCandidates(10),
        settings: const QuizSettings(optionCount: 4, distractors: DistractorStrategy.confusion),
      );
      expect(engine.next()!.optionIds, hasLength(4));
    });
  });

  group('same-initial distractors', () {
    test('pulls in people sharing the first letter', () {
      final engine = engineWith(
        [
          const CandidateStats(personId: 1, box: 1, wrong: 0, initial: 'M'),
          const CandidateStats(personId: 2, box: 1, wrong: 0, initial: 'M'),
          const CandidateStats(personId: 3, box: 1, wrong: 0, initial: 'M'),
          for (var i = 4; i <= 12; i++) CandidateStats(personId: i, box: 1, wrong: 0, initial: 'Z'),
        ],
        settings: const QuizSettings(optionCount: 3, distractors: DistractorStrategy.sameInitial),
      );

      for (var i = 0; i < 100; i++) {
        final question = engine.next()!;
        if (question.personId == 1) {
          expect(question.optionIds, containsAll([1, 2, 3]));
          return;
        }
      }
      fail('person 1 was never asked about');
    });
  });

  group('person selection', () {
    test('shows everyone once before repeating', () {
      final engine = engineWith(plainCandidates(8));
      final asked = {for (var i = 0; i < 8; i++) engine.next()!.personId};
      expect(asked, hasLength(8));
    });

    test('does not ask the same person twice in a row', () {
      final engine = engineWith(plainCandidates(5));
      var previous = engine.next()!.personId;
      for (var i = 0; i < 40; i++) {
        final current = engine.next()!.personId;
        expect(current, isNot(previous));
        previous = current;
      }
    });

    test('weights people in low Leitner boxes more heavily', () {
      final engine = engineWith([
        const CandidateStats(personId: 1, box: 1, wrong: 10),
        for (var i = 2; i <= 6; i++) CandidateStats(personId: i, box: 5, wrong: 0),
      ]);

      // Past the first pass everyone has been seen once, so weighting decides.
      for (var i = 0; i < 6; i++) {
        engine.next();
      }
      var struggling = 0;
      for (var i = 0; i < 120; i++) {
        if (engine.next()!.personId == 1) struggling++;
      }
      expect(struggling, greaterThan(120 / 6), reason: 'box 1 should come up more than uniform chance');
    });
  });

  group('Leitner movement', () {
    test('a correct answer moves up one box, capped at 5', () {
      final engine = engineWith([
        const CandidateStats(personId: 1, box: 5, wrong: 0),
        const CandidateStats(personId: 2, box: 1, wrong: 0),
      ]);
      engine.applyAnswer(personId: 1, correct: true);
      engine.applyAnswer(personId: 2, correct: true);
      expect(engine.boxOf(1), 5);
      expect(engine.boxOf(2), 2);
    });

    test('a wrong answer drops two boxes, floored at 1', () {
      final engine = engineWith([
        const CandidateStats(personId: 1, box: 5, wrong: 0),
        const CandidateStats(personId: 2, box: 2, wrong: 0),
      ]);
      engine.applyAnswer(personId: 1, correct: false);
      engine.applyAnswer(personId: 2, correct: false);
      expect(engine.boxOf(1), 3);
      expect(engine.boxOf(2), 1);
    });
  });
}
