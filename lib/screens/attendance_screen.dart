import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';

/// Who is here today.
///
/// Set once at the start of the lesson and it holds for the draw and, later,
/// the grouping. Absences are stored per day and produce no draw event, so
/// being away never uses up a turn — which is exactly why this belongs before
/// the draw and not as a correction after it.
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(schoolClass.id));
    final absent = ref.watch(absencesProvider(schoolClass.id)).valueOrNull ?? const <int>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anwesenheit'),
        actions: [
          TextButton.icon(
            onPressed: absent.isEmpty ? null : () => _allPresent(ref),
            icon: const Icon(Icons.done_all),
            label: const Text('Alle da'),
          ),
        ],
      ),
      body: students.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${list.length - absent.length} von ${list.length} anwesend — '
                'antippen, wer heute fehlt.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final student = list[index];
                  return _AttendanceCard(
                    student: student,
                    absent: absent.contains(student.id),
                    onTap: () => _toggle(ref, student, !absent.contains(student.id)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, Student student, bool absent) async {
    await ref.read(selectionRepositoryProvider).setAbsent(
          classId: schoolClass.id,
          studentId: student.id,
          day: DateTime.now(),
          absent: absent,
        );
    _refresh(ref);
  }

  Future<void> _allPresent(WidgetRef ref) async {
    final repo = ref.read(selectionRepositoryProvider);
    final absent = await repo.absencesOn(schoolClass.id, DateTime.now());
    for (final studentId in absent) {
      await repo.setAbsent(
        classId: schoolClass.id,
        studentId: studentId,
        day: DateTime.now(),
        absent: false,
      );
    }
    _refresh(ref);
  }

  /// The pool is derived from the absences, so it has to be recomputed with
  /// them — otherwise the draw screen keeps showing yesterday's count.
  void _refresh(WidgetRef ref) {
    ref.invalidate(absencesProvider(schoolClass.id));
    ref.invalidate(poolProvider(schoolClass.id));
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.student, required this.absent, required this.onTap});

  final Student student;
  final bool absent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Greyed out rather than faded away: the face has to stay
                  // recognisable, or you cannot tell whom you just marked.
                  ColorFiltered(
                    colorFilter: absent
                        ? const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0, //
                            0.2126, 0.7152, 0.0722, 0, 0, //
                            0.2126, 0.7152, 0.0722, 0, 0, //
                            0, 0, 0, 0.45, 0,
                          ])
                        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                    child: Image.memory(
                      student.jpegBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  if (absent)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.block, color: theme.colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                student.firstName.isEmpty ? student.lastName : student.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: absent ? theme.colorScheme.onSurfaceVariant : null,
                  decoration: absent ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
