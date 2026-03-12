import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/notes_provider.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../models/schedule_entry.dart';
import '../models/subject.dart';
import 'add_schedule_page.dart';
import 'add_subject_page.dart';

/// Main schedule screen – displays subjects and their weekly time slots.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pushAddSubject(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.subjects.isEmpty) {
            return _EmptyState(onAdd: () => _pushAddSubject(context));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: provider.subjects.length,
            itemBuilder: (context, i) {
              final subject = provider.subjects[i];
              final entries = provider.entriesForSubject(subject.id!);
              return _SubjectCard(
                subject: subject,
                entries: entries,
                onDeleteSubject: () =>
                    _confirmDeleteSubject(context, provider, subject),
                onAddEntry: () =>
                    _pushAddSchedule(context, subject),
                onDeleteEntry: (e) =>
                    provider.deleteScheduleEntry(e.id!),
              );
            },
          );
        },
      ),
    );
  }

  void _pushAddSubject(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddSubjectPage()),
      );

  void _pushAddSchedule(BuildContext context, Subject subject) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddSchedulePage(subject: subject)),
      );

  void _confirmDeleteSubject(
    BuildContext context,
    ScheduleProvider provider,
    Subject subject,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Delete "${subject.name}" and all its schedule entries?\n'
          'Associated notes will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteSubject(subject.id!);
              if (!context.mounted) return;
              context.read<NotesProvider>().removeNotesBySubject(subject.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 72, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text('No subjects yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add your first subject and set up its weekly schedule.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subject card ──────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final List<ScheduleEntry> entries;
  final VoidCallback onDeleteSubject;
  final VoidCallback onAddEntry;
  final void Function(ScheduleEntry) onDeleteEntry;

  const _SubjectCard({
    required this.subject,
    required this.entries,
    required this.onDeleteSubject,
    required this.onAddEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    subject.name[0].toUpperCase(),
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: cs.error),
                  tooltip: 'Delete subject',
                  onPressed: onDeleteSubject,
                ),
              ],
            ),
            // ── Schedule entries ─────────────────────────────────────────────
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No schedule added.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              )
            else ...[
              const Divider(height: 20),
              ...entries.map(
                (e) => _ScheduleRow(
                  entry: e,
                  onDelete: () => onDeleteEntry(e),
                ),
              ),
            ],
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onAddEntry,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Schedule'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Schedule row ──────────────────────────────────────────────────────────────

class _ScheduleRow extends StatelessWidget {
  final ScheduleEntry entry;
  final VoidCallback onDelete;

  const _ScheduleRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              AppConstants.weekdayNames[entry.weekday - 1],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${entry.startTime} – ${entry.endTime}',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: cs.outlineVariant),
          ),
        ],
      ),
    );
  }
}
