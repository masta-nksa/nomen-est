import 'package:flutter/material.dart';

import '../data/database.dart';
import '../widgets/photo_zoom.dart';
import 'quiz_screen.dart';

/// Round summary: hit rate, worst performers, and the confusion pairs.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.schoolClass,
    required this.answers,
    required this.students,
  });

  final SchoolClass schoolClass;
  final List<AnswerRecord> answers;
  final Map<int, Student> students;

  @override
  Widget build(BuildContext context) {
    final correct = answers.where((a) => a.correct).length;
    final mistakesByStudent = <int, int>{};
    final confusionPairs = <(int, int), int>{};
    for (final answer in answers.where((a) => !a.correct)) {
      mistakesByStudent.update(answer.studentId, (v) => v + 1, ifAbsent: () => 1);
      if (answer.pickedId != null) {
        final key = (answer.studentId, answer.pickedId!);
        confusionPairs.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final worst = mistakesByStudent.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final pairs = confusionPairs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Auswertung')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        answers.isEmpty ? '—' : '${(correct / answers.length * 100).round()} %',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text('$correct von ${answers.length} richtig'),
                    ],
                  ),
                ),
              ),
              if (worst.isNotEmpty) ...[
                _heading(context, 'Am häufigsten falsch'),
                for (final entry in worst.take(5))
                  ListTile(
                    leading: _avatar(context, students[entry.key]),
                    title: Text(students[entry.key]?.displayName ?? '?'),
                    trailing: Text('${entry.value}×'),
                  ),
              ],
              if (pairs.isNotEmpty) ...[
                _heading(context, 'Verwechslungen'),
                for (final entry in pairs.take(5))
                  ListTile(
                    leading: _avatar(context, students[entry.key.$1]),
                    title: Text(
                      'Du verwechselst ${students[entry.key.$1]?.displayName ?? '?'} '
                      'mit ${students[entry.key.$2]?.displayName ?? '?'}',
                    ),
                    trailing: Text('${entry.value}×'),
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Fertig'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _avatar(BuildContext context, Student? student) {
    if (student == null) return const CircleAvatar(child: Icon(Icons.person));
    return SizedBox(
      width: 40,
      height: 40,
      child: ZoomablePhoto(
        jpegBytes: student.jpegBytes,
        caption: student.displayName,
        borderRadius: 20,
      ),
    );
  }
}
