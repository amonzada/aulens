import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/notes_provider.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../models/note.dart';

/// Full-detail view for a single note: photo, metadata and selectable OCR text.
class NoteDetailPage extends StatelessWidget {
  final Note note;
  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleProvider>();
    final subject = schedule.subjectById(note.subjectId);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject?.name ?? 'Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: cs.error),
            tooltip: 'Delete note',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Photo ──────────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(
                File(note.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 56,
                    color: cs.outlineVariant,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Metadata row ──────────────────────────────────────────
                  _MetaRow(
                    icon: Icons.schedule,
                    text: DateFormat('EEEE, MMMM d, yyyy · HH:mm')
                        .format(note.createdAt),
                  ),
                  if (subject != null) ...[
                    const SizedBox(height: 4),
                    _MetaRow(
                      icon: Icons.school_outlined,
                      text: subject.name,
                    ),
                  ],
                  const SizedBox(height: 20),

                  // ── OCR text ──────────────────────────────────────────────
                  Text('Extracted Text', style: theme.textTheme.titleSmall),
                  const Divider(height: 12),
                  if (note.ocrText != null)
                    SelectableText(
                      note.ocrText!,
                      style: theme.textTheme.bodyMedium,
                    )
                  else
                    Text(
                      'No text was extracted from this image.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'This note and its image file will be permanently deleted.',
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
              await context.read<NotesProvider>().deleteNote(note.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Metadata row widget ───────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
