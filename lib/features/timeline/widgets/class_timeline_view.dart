import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../notes/models/note.dart';
import '../models/class_session.dart';
import '../models/photo_group.dart';

/// Session-first notes layout:
/// Class session -> Photo groups -> Text notes.
class ClassTimelineView extends StatelessWidget {
  final List<ClassSession> sessions;
  final ValueChanged<Note>? onNoteTap;

  const ClassTimelineView({
    super.key,
    required this.sessions,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const _EmptyClassNotes();
    }

    return Column(
      children: sessions
          .map((session) => _SessionCard(session: session, onNoteTap: onNoteTap))
          .toList(),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ClassSession session;
  final ValueChanged<Note>? onNoteTap;

  const _SessionCard({required this.session, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateLabel = DateFormat('EEE, MMM d, yyyy').format(session.date);
    final timeLabel = session.isUnscheduled
        ? 'Unscheduled'
        : '${session.startTime} – ${session.endTime}';

    final sortedNotes = [...session.notes]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final photoGroups = _collectPhotoGroups(session, sortedNotes);
    final textNotes = sortedNotes.where((n) => n.isTextNote).toList();
    final failedProcessing =
        session.processingNotes.where((p) => p.failed).toList(growable: false);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateLabel,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                timeLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _CountChip(
                icon: Icons.photo_library_outlined,
                label: '${photoGroups.length} photo group${photoGroups.length == 1 ? '' : 's'}',
              ),
              _CountChip(
                icon: Icons.notes_outlined,
                label: '${textNotes.length} text note${textNotes.length == 1 ? '' : 's'}',
              ),
            ],
          ),
          if (photoGroups.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionTitle(title: 'Photo Groups'),
            const SizedBox(height: 8),
            ...photoGroups.map(
              (group) => _PhotoGroupCard(group: group, onNoteTap: onNoteTap),
            ),
          ],
          if (textNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionTitle(title: 'Text Notes'),
            const SizedBox(height: 8),
            ...textNotes.map(
              (note) => _TextNoteTile(note: note, onNoteTap: onNoteTap),
            ),
          ],
          if (photoGroups.isEmpty && textNotes.isEmpty && failedProcessing.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'No notes in this session.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          if (failedProcessing.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Some OCR jobs failed. You can retake these photos from Camera.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
        ],
      ),
    );
  }
}

List<PhotoGroup> _collectPhotoGroups(ClassSession session, List<Note> notes) {
  const groupWindow = Duration(minutes: 2);
  final groups = <PhotoGroup>[];
  int i = 0;

  while (i < notes.length) {
    final current = notes[i];
    if (current.isTextNote) {
      i += 1;
      continue;
    }

    final grouped = <Note>[current];
    var last = current;
    var j = i + 1;

    while (j < notes.length) {
      final candidate = notes[j];
      if (candidate.isTextNote) break;
      if (candidate.createdAt.difference(last.createdAt) <= groupWindow) {
        grouped.add(candidate);
        last = candidate;
        j += 1;
      } else {
        break;
      }
    }

    groups.add(
      PhotoGroup(
        subject: session.subject,
        timestamp: grouped.first.createdAt,
        photos: grouped,
      ),
    );

    i = j;
  }

  return groups;
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CountChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _PhotoGroupCard extends StatelessWidget {
  final PhotoGroup group;
  final ValueChanged<Note>? onNoteTap;

  const _PhotoGroupCard({required this.group, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = group.photos.length;
    final label = DateFormat('HH:mm').format(group.timestamp);
    final cover = group.photos.first.imagePath;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showGroupSheet(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              if (cover != null && cover.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(cover),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _FallbackThumb(icon: Icons.broken_image_outlined),
                  ),
                )
              else
                const _FallbackThumb(icon: Icons.photo_library_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$label  •  $count photo${count == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showGroupSheet(BuildContext context) async {
    final ordered = [...group.photos]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ordered.length,
          itemBuilder: (context, index) {
            final note = ordered[index];
            final time = DateFormat('HH:mm').format(note.createdAt);
            return ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: Text('Photo $time'),
              onTap: () {
                Navigator.pop(context);
                if (onNoteTap != null) onNoteTap!(note);
              },
            );
          },
        ),
      ),
    );
  }
}

class _TextNoteTile extends StatelessWidget {
  final Note note;
  final ValueChanged<Note>? onNoteTap;

  const _TextNoteTile({required this.note, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    final preview = _snippetText(note.textContent) ?? 'No text available.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
        leading: const Icon(Icons.note_alt_outlined),
        title: Text(DateFormat('HH:mm').format(note.createdAt)),
        subtitle: Text(
          preview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onNoteTap == null ? null : () => onNoteTap!(note),
      ),
    );
  }
}

class _FallbackThumb extends StatelessWidget {
  final IconData icon;

  const _FallbackThumb({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: cs.outlineVariant),
    );
  }
}

String? _snippetText(String? text) {
  if (text == null) return null;
  final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.isEmpty) return null;
  if (compact.length <= 120) return compact;
  return '${compact.substring(0, 120)}...';
}

class _EmptyClassNotes extends StatelessWidget {
  const _EmptyClassNotes();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(Icons.menu_book_outlined, color: cs.outline, size: 22),
            const SizedBox(height: 10),
            Text(
              'No sessions yet. Tap the camera or add a text note to start.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
