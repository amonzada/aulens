import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../timeline/widgets/class_timeline_view.dart';
import '../models/processing_note.dart';
import '../../../shared/providers/notes_provider.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../models/note.dart';
import 'note_detail_page.dart';

/// Notes tab – shows all subjects with sleek timeline feed sections.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Consumer2<ScheduleProvider, NotesProvider>(
        builder: (context, schedule, notes, _) {
          if (notes.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (schedule.subjects.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: schedule.subjects.length,
            itemBuilder: (context, i) {
              final subject = schedule.subjects[i];
              return _SubjectExpansion(
                subjectName: subject.name,
                notes: notes.notesForSubject(subject.id!),
                processingNotes: notes.processingNotesForSubject(subject.id!),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 72, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text('No notes yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Capture whiteboard photos from the Camera tab\n'
              'to start building your collection.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subject expansion tile ────────────────────────────────────────────────────

class _SubjectExpansion extends StatelessWidget {
  final String subjectName;
  final List<Note> notes;
  final List<ProcessingNote> processingNotes;

  const _SubjectExpansion({
    required this.subjectName,
    required this.notes,
    required this.processingNotes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            subjectName[0].toUpperCase(),
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${notes.length + processingNotes.length} item${notes.length + processingNotes.length == 1 ? '' : 's'}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        children: [
          ClassTimelineView(
            notes: notes,
            processingNotes: processingNotes,
            onNoteTap: (note) => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
            ),
          ),
        ],
      ),
    );
  }
}
