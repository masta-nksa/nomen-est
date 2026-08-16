import 'package:flutter/material.dart';

import '../data/database.dart';
import '../quiz/quiz_settings.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key, required this.schoolClass});

  final SchoolClass schoolClass;

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  QuizSettings _settings = const QuizSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.schoolClass.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Modus'),
          SegmentedButton<QuizMode>(
            segments: const [
              ButtonSegment(value: QuizMode.photoToName, label: Text('Foto → Name')),
              ButtonSegment(value: QuizMode.nameToPhoto, label: Text('Name → Foto')),
            ],
            selected: {_settings.mode},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(mode: v.first)),
          ),
          _section('Voreinstellung'),
          Wrap(
            spacing: 8,
            children: [
              _presetChip('Leicht', QuizSettings.easy),
              _presetChip('Mittel', QuizSettings.medium),
              _presetChip('Schwer', QuizSettings.hard),
            ],
          ),
          _section('Anzahl Optionen'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 8, label: Text('8')),
            ],
            selected: {_settings.optionCount},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(optionCount: v.first)),
          ),
          _section('Ablenker'),
          SegmentedButton<DistractorStrategy>(
            segments: const [
              ButtonSegment(value: DistractorStrategy.random, label: Text('Zufällig')),
              ButtonSegment(value: DistractorStrategy.sameInitial, label: Text('Gleicher Buchstabe')),
              ButtonSegment(value: DistractorStrategy.confusion, label: Text('Verwechslungen')),
            ],
            selected: {_settings.distractors},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(distractors: v.first)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Verwechslungen: Es werden bevorzugt die Personen angeboten, die du bei dieser '
              'Person schon einmal fälschlich gewählt hast.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _section('Zeitlimit'),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Keins')),
              ButtonSegment(value: 8, label: Text('8 s')),
              ButtonSegment(value: 4, label: Text('4 s')),
            ],
            selected: {_settings.timeLimit?.inSeconds ?? 0},
            onSelectionChanged: (v) => setState(() {
              final seconds = v.first;
              _settings = seconds == 0
                  ? _settings.copyWith(clearTimeLimit: true)
                  : _settings.copyWith(timeLimit: Duration(seconds: seconds));
            }),
          ),
          _section('Angezeigter Name'),
          SegmentedButton<NameStyle>(
            segments: const [
              ButtonSegment(value: NameStyle.firstName, label: Text('Vorname')),
              ButtonSegment(value: NameStyle.lastName, label: Text('Nachname')),
              ButtonSegment(value: NameStyle.full, label: Text('Beides')),
            ],
            selected: {_settings.nameStyle},
            onSelectionChanged: (v) => setState(() => _settings = _settings.copyWith(nameStyle: v.first)),
          ),
          _section('Runde'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _settings.roundLength.toDouble(),
                  min: 5,
                  max: 40,
                  divisions: 7,
                  label: '${_settings.roundLength} Karten',
                  onChanged: (v) => setState(() => _settings = _settings.copyWith(roundLength: v.round())),
                ),
              ),
              Text('${_settings.roundLength} Karten'),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(schoolClass: widget.schoolClass, settings: _settings),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Runde starten'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _presetChip(String label, QuizSettings preset) => ActionChip(
        label: Text(label),
        onPressed: () => setState(() => _settings = preset.copyWith(
              mode: _settings.mode,
              nameStyle: _settings.nameStyle,
              roundLength: _settings.roundLength,
            )),
      );
}
