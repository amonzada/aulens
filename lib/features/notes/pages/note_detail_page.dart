import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/providers/notes_provider.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../../schedule/models/subject.dart';
import 'full_screen_photo_viewer_page.dart';
import '../models/note.dart';

/// Full-detail view for a single note: photo, metadata and selectable OCR text.
class NoteDetailPage extends StatefulWidget {
  final Note note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final schedule = context.watch<ScheduleProvider>();
    final subject = schedule.subjectById(_note.subjectId);
    final subjectPhotos = notesProvider
        .notesForSubject(_note.subjectId)
        .where((n) => n.hasImage)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final initialPhotoIndex = subjectPhotos.indexWhere((n) => n.id == _note.id);
    final galleryInitialIndex = initialPhotoIndex >= 0 ? initialPhotoIndex : 0;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject?.name ?? 'Note'),
        actions: [
          if (_note.hasImage)
            IconButton(
              icon: const Icon(Icons.drive_file_move_outline),
              tooltip: 'Move photo to another subject',
              onPressed: () => _moveToAnotherSubject(context),
            ),
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
            if (_note.hasImage) ...[
              // ── Photo ──────────────────────────────────────────────────
              AspectRatio(
                aspectRatio: 4 / 3,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenPhotoViewerPage(
                        photos: subjectPhotos,
                        initialIndex: galleryInitialIndex,
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: _photoHeroTag(_note),
                    child: Image.file(
                      File(_note.imagePath!),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
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
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Metadata row ──────────────────────────────────────────
                  _MetaRow(
                    icon: Icons.schedule,
                    text: DateFormat('EEEE, MMMM d, yyyy · HH:mm')
                    .format(_note.createdAt),
                  ),
                  if (subject != null) ...[
                    const SizedBox(height: 4),
                    _MetaRow(
                      icon: Icons.school_outlined,
                      text: subject.name,
                    ),
                  ],
                  const SizedBox(height: 20),

                  if (_note.isTextNote) ...[
                    Text('Note', style: theme.textTheme.titleSmall),
                    const Divider(height: 12),
                    SelectableText(
                      _note.textContent ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ] else ...[
                    // ── OCR text ─────────────────────────────────────────
                    Text('Extracted Text', style: theme.textTheme.titleSmall),
                    const Divider(height: 12),
                    if (_note.ocrText != null)
                      SelectableText(
                        _note.ocrText!,
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
        content: Text(
          _note.hasImage
              ? 'This note and its image file will be permanently deleted.'
              : 'This note will be permanently deleted.',
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
                await context.read<NotesProvider>().deleteNote(_note.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

    Future<void> _moveToAnotherSubject(BuildContext context) async {
      final scheduleProvider = context.read<ScheduleProvider>();
      final notesProvider = context.read<NotesProvider>();

      final subjects = scheduleProvider.subjects
          .where((s) => s.id != _note.subjectId)
          .toList();

      if (subjects.isEmpty) {
        AppSnackBar.showInfo(
          context,
          'No other subjects available to move this photo.',
        );
        return;
      }

      final target = await showModalBottomSheet<Subject>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(subject.name),
                onTap: () => Navigator.pop(context, subject),
              );
            },
          ),
        ),
      );

      if (target == null || target.id == null || _note.id == null) return;

      await notesProvider.moveNoteToSubject(
        noteId: _note.id!,
        targetSubjectId: target.id!,
      );

      if (!mounted) return;
      setState(() => _note = _note.copyWith(subjectId: target.id));
      AppSnackBar.showInfo(this.context, 'Photo moved to ${target.name}.');
    }
}

String _photoHeroTag(Note note) {
  return 'note-photo-${note.id ?? note.imagePath}-${note.createdAt.millisecondsSinceEpoch}';
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
