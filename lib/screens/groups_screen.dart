import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../groups/group_builder.dart';
import '../groups/group_settings.dart';
import '../groups/partition.dart';
import '../widgets/mode_chip_bar.dart';
import 'attendance_screen.dart';

/// Splits the class into groups.
///
/// The setup stays on screen next to the result rather than behind a wizard:
/// the common case is stating a size and rolling, and re-rolling after seeing
/// the outcome is the second most common thing anyone does here.
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  List<List<Student>>? _result;

  int get _classId => widget.schoolClass.id;

  @override
  Widget build(BuildContext context) {
    final present = ref.watch(presentStudentsProvider(_classId)).valueOrNull ?? const <Student>[];
    final settings = ref.watch(groupSettingsProvider(_classId)).valueOrNull ?? const GroupSettings();
    final plan = partition(students: present.length, spec: settings.spec, even: settings.even);

    return Scaffold(
      appBar: AppBar(title: Text(widget.schoolClass.label)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: _result == null
                        ? _Setup(
                            settings: settings,
                            plan: plan,
                            present: present.length,
                            onChanged: _save,
                          )
                        : _Result(groups: _result!),
                  ),
                  const SizedBox(height: 12),
                  ModeChipBar(chips: _chips(settings, present)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_result != null) ...[
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _result = null),
                          icon: const Icon(Icons.tune),
                          label: const Text('Ändern'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: plan is Partition && plan.groups > 0 ? () => _build(present, plan) : null,
                          icon: const Icon(Icons.casino),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(_result == null ? 'Würfeln' : 'Neu würfeln'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChip> _chips(GroupSettings settings, List<Student> present) {
    final total = ref.watch(studentsProvider(_classId)).valueOrNull?.length ?? present.length;
    return [
      ModeChip(
        label: 'gleichmässig',
        iconOn: Icons.horizontal_distribute,
        iconOff: Icons.format_align_left,
        on: settings.even,
        explanation: settings.even
            ? 'Die Gruppen unterscheiden sich um höchstens eine Person.'
            : 'Gruppen werden auf die genannte Grösse gefüllt, der Rest bildet '
                'eine kleinere Gruppe.',
        onTap: () => _save(settings.copyWith(even: !settings.even)),
      ),
      StatusChip(
        label: '${present.length}/$total da',
        icon: Icons.how_to_reg,
        explanation: 'Eingeteilt wird, wer heute anwesend ist.',
        onTap: _openAttendance,
      ),
    ];
  }

  Future<void> _save(GroupSettings settings) async {
    await ref.read(groupSettingsProvider(_classId).notifier).save(settings);
    if (mounted) setState(() => _result = null);
  }

  Future<void> _openAttendance() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AttendanceScreen(schoolClass: widget.schoolClass),
    ));
    ref.invalidate(presentStudentsProvider(_classId));
    if (mounted) setState(() => _result = null);
  }

  void _build(List<Student> present, Partition plan) {
    final byId = {for (final student in present) student.id: student};
    final groups = GroupBuilder.assign(
      studentIds: [for (final student in present) student.id],
      sizes: plan.sizes,
      random: Random(),
    );
    setState(() {
      _result = [
        for (final group in groups) [for (final id in group) byId[id]!],
      ];
    });
  }
}

class _Setup extends StatelessWidget {
  const _Setup({
    required this.settings,
    required this.plan,
    required this.present,
    required this.onChanged,
  });

  final GroupSettings settings;
  final PartitionResult plan;
  final int present;
  final void Function(GroupSettings) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        SegmentedButton<GroupMode>(
          segments: const [
            ButtonSegment(value: GroupMode.count, label: Text('Anzahl')),
            ButtonSegment(value: GroupMode.size, label: Text('Grösse')),
            ButtonSegment(value: GroupMode.range, label: Text('Bereich')),
          ],
          selected: {settings.mode},
          onSelectionChanged: (value) => onChanged(settings.copyWith(mode: value.first)),
        ),
        const SizedBox(height: 20),
        switch (settings.mode) {
          GroupMode.count => _Stepper(
              label: 'Anzahl Gruppen',
              value: settings.groups,
              min: 1,
              max: present == 0 ? 1 : present,
              onChanged: (value) => onChanged(settings.copyWith(groups: value)),
            ),
          GroupMode.size => _Stepper(
              label: 'Personen pro Gruppe',
              value: settings.size,
              min: 1,
              max: present == 0 ? 1 : present,
              onChanged: (value) => onChanged(settings.copyWith(size: value)),
            ),
          GroupMode.range => Column(
              children: [
                _Stepper(
                  label: 'mindestens',
                  value: settings.min,
                  min: 1,
                  max: settings.max,
                  onChanged: (value) => onChanged(settings.copyWith(min: value)),
                ),
                const SizedBox(height: 12),
                _Stepper(
                  label: 'höchstens',
                  value: settings.max,
                  min: settings.min,
                  max: present == 0 ? 1 : present,
                  onChanged: (value) => onChanged(settings.copyWith(max: value)),
                ),
              ],
            ),
        },
        const SizedBox(height: 28),
        // The consequence of the choice, never just "not possible": an
        // impossible split names a way out.
        switch (plan) {
          Partition(:final sizes) when sizes.isEmpty => Text(
              'Heute ist niemand da.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          Partition() => Text(
              'ergibt ${(plan as Partition).describe()}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          PartitionImpossible(:final message, :final suggestion) => Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
                ),
                if (suggestion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(suggestion, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
        },
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.groups});

  final List<List<Student>> groups;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) => _GroupCard(index: index, members: groups[index]),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.index, required this.members});

  final int index;
  final List<Student> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gruppe ${index + 1} · ${members.length}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final student in members) _MemberChip(student: student)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: ClipOval(
        child: Image.memory(
          student.jpegBytes,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
      label: Text(student.firstName.isEmpty ? student.lastName : student.firstName),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
