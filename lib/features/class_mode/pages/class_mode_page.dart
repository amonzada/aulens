import 'package:flutter/material.dart';
import '../../notes/pages/add_text_note_page.dart';
import '../../schedule/models/schedule_entry.dart';
import '../../schedule/models/subject.dart';
import '../../camera/pages/camera_page.dart';

/// Full-screen class mode for quick capture during an active session.
class ClassModePage extends StatefulWidget {
  final Subject detectedSubject;
  final ScheduleEntry scheduleEntry;
  final List<Subject> subjects;

  const ClassModePage({
    super.key,
    required this.detectedSubject,
    required this.scheduleEntry,
    required this.subjects,
  });
  @override
  State<ClassModePage> createState() => _ClassModePageState();
}

class _ClassModePageState extends State<ClassModePage> {
  late Subject _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.detectedSubject;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entry = widget.scheduleEntry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close class mode',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _selectedSubject.name,
              style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_selectedSubject.professor != null &&
                _selectedSubject.professor!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Prof. ${_selectedSubject.professor}',
                  style: theme.textTheme.titleMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            if (_selectedSubject.classroom != null &&
                _selectedSubject.classroom!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Room ${_selectedSubject.classroom}',
                  style: theme.textTheme.titleMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${entry.startTime} – ${entry.endTime}',
                style: theme.textTheme.titleMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Focus and close your cell phone asap.',
                style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Text('Subject override', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<Subject>(
              key: ValueKey(_selectedSubject.id),
              initialValue: _selectedSubject,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.school_outlined),
                labelText: 'Subject',
              ),
              items: widget.subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (s) {
                if (s == null) return;
                setState(() => _selectedSubject = s);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.camera_alt_outlined, size: 22),
              label: const Text('Take Photo'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraPage(
                      autoCapture: true,
                      fixedSubject: _selectedSubject,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.note_add_outlined, size: 22),
              label: const Text('Add Text Note'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTextNotePage(subject: _selectedSubject),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Captured notes will be saved to this subject and session.',
              style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
