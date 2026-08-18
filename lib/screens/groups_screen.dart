import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../groups/group_builder.dart';
import '../groups/group_settings.dart';
import '../groups/partition.dart';
import '../widgets/mode_chip_bar.dart';
import '../widgets/presentation.dart';
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

  /// Null until the teacher decides for themselves; an explicit choice then
  /// outranks the automatic guess for as long as the screen is open.
  bool? _presenting;

  int get _classId => widget.schoolClass.id;

  @override
  Widget build(BuildContext context) {
    final present = ref.watch(presentStudentsProvider(_classId)).valueOrNull ?? const <Student>[];
    final settings = ref.watch(groupSettingsProvider(_classId)).valueOrNull ?? const GroupSettings();
    final plan = partition(students: present.length, spec: settings.spec, even: settings.even);

    // Nothing to show a room until the groups exist — the setup steppers are
    // for the teacher alone.
    final presenting = _result != null && (_presenting ?? suggestsPresentation(context));

    return Scaffold(
      appBar: presenting
          ? null
          : AppBar(
              title: Text(widget.schoolClass.label),
              actions: [
                if (_result != null)
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    tooltip: 'Für den Beamer',
                    onPressed: () => setState(() => _presenting = true),
                  ),
              ],
            ),
      body: SafeArea(
        child: presenting
            ? PresentationScaffold(
                presenting: true,
                onExit: () => setState(() => _presenting = false),
                onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: _Result(groups: _result!, presenting: true),
                ),
                controlsBuilder: (context, visible) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModeChipBar(chips: _chips(settings, present), dimmed: !visible),
                    const SizedBox(height: 12),
                    PresentationFade(hide: !visible, child: _actions(present, plan)),
                  ],
                ),
              )
            : Center(
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
                              : _Result(groups: _result!, presenting: false),
                        ),
                        const SizedBox(height: 12),
                        ModeChipBar(chips: _chips(settings, present)),
                        const SizedBox(height: 12),
                        _actions(present, plan),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _actions(List<Student> present, PartitionResult plan) {
    return Row(
      children: [
        if (_result != null) ...[
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _result = null;
              _presenting = null;
            }),
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
  const _Result({required this.groups, required this.presenting});

  final List<List<Student>> groups;
  final bool presenting;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Wider cards at the beamer means fewer of them, which is what makes the
      // faces inside big enough to recognise from the back row.
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: presenting ? 520 : 320,
        // Wide and shallow at the beamer: four portraits fit in one row, so a
        // card is barely taller than a single photo and many groups fit on
        // screen without scrolling.
        childAspectRatio: presenting ? 1.6 : 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) => _GroupCard(
        index: index,
        members: groups[index],
        presenting: presenting,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.index, required this.members, required this.presenting});

  final int index;
  final List<Student> members;
  final bool presenting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: LayoutBuilder(builder: (context, constraints) {
        // Derived from the card rather than fixed: the same 28 px that read
        // fine on a laptop are a smudge on a beamer, and a card that grew has
        // the room to spend.
        final avatar = (constraints.maxWidth * 0.13).clamp(28.0, 96.0);
        final padding = presenting ? 16.0 : avatar * 0.3;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Without the member count: "Gruppe 4 · 5" reads like a range,
              // and the number of faces below is quicker to see than to read.
              Text(
                'Gruppe ${index + 1}',
                style: presenting || avatar > 44
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.titleSmall,
              ),
              SizedBox(height: presenting ? 12 : avatar * 0.25),
              Expanded(
                child: SingleChildScrollView(
                  child: presenting
                      ? _Portraits(members: members, cardWidth: constraints.maxWidth - padding * 2)
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final student in members)
                              _MemberChip(student: student, avatar: avatar),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// The members as square photos with the name underneath.
///
/// A round avatar beside text is the right shape at arm's length and the wrong
/// one at eight metres, where the face has to do the work of recognition and
/// needs the whole tile to do it in.
///
/// The tile is a quarter of the card whatever the group size. Sizing it by the
/// number of members would blow up a pair of students to fill the card and give
/// the beamer faces of two different sizes; a fixed quarter keeps every face
/// equal and every card one row deep.
class _Portraits extends StatelessWidget {
  const _Portraits({required this.members, required this.cardWidth});

  final List<Student> members;
  final double cardWidth;

  static const _perRow = 4;

  @override
  Widget build(BuildContext context) {
    const spacing = 10.0;
    final tile = (cardWidth - spacing * (_perRow - 1)) / _perRow;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: [
        for (final student in members) _MemberTile(student: student, width: tile),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.student, required this.width});

  final Student student;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.memory(
                student.jpegBytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            student.firstName.isEmpty ? student.lastName : student.firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.student, required this.avatar});

  final Student student;
  final double avatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: ClipOval(
        child: Image.memory(
          student.jpegBytes,
          width: avatar,
          height: avatar,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
      label: Text(
        student.firstName.isEmpty ? student.lastName : student.firstName,
        style: avatar > 44 ? theme.textTheme.titleMedium : null,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: avatar * 0.18),
      visualDensity: avatar > 44 ? VisualDensity.standard : VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.secondaryContainer,
    );
  }
}
