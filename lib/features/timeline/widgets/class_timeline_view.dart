import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../notes/models/note.dart';
import '../../notes/models/processing_note.dart';
import '../models/class_session.dart';
import '../models/photo_group.dart';
import '../models/timeline_item.dart';

/// Vertical timeline grouped by class session.
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
          .map((session) => _TimelineGroupSection(
                session: session,
                onNoteTap: onNoteTap,
              ))
          .toList(),
    );
  }
}

class _TimelineGroupSection extends StatelessWidget {
  final ClassSession session;
  final ValueChanged<Note>? onNoteTap;

  const _TimelineGroupSection({
    required this.session,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateLabel = DateFormat('EEE, MMM d, yyyy').format(session.date);
    final totalItems =
        session.notes.length + session.processingNotes.length;
    final timeLabel = session.isUnscheduled
        ? 'Unscheduled'
        : '${session.startTime} – ${session.endTime}';
    final entries = _buildEntries(session);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$totalItems item${totalItems == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...session.processingNotes
              .map((p) => _ProcessingNodeTile(note: p)),
          if (entries.isEmpty && session.processingNotes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 60, top: 4),
              child: Text(
                'No notes in this session.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            ...List.generate(
              entries.length,
              (index) {
                final entry = entries[index];
                final isLast = index == entries.length - 1;
                if (entry.photoGroup != null) {
                  return _PhotoGroupTile(
                    group: entry.photoGroup!,
                    isLast: isLast,
                    onNoteTap: onNoteTap,
                  );
                }

                return _TimelineNodeTile(
                  item: entry.item!,
                  isLast: isLast,
                  onTap: onNoteTap,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SessionEntry {
  final TimelineItem? item;
  final PhotoGroup? photoGroup;

  const _SessionEntry({this.item, this.photoGroup});
}

List<_SessionEntry> _buildEntries(ClassSession session) {
  const groupWindow = Duration(minutes: 2);
  final notes = [...session.notes]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final entries = <_SessionEntry>[];

  int i = 0;
  while (i < notes.length) {
    final current = notes[i];

    if (current.isTextNote) {
      entries.add(_SessionEntry(item: _toTimelineItem(current)));
      i += 1;
      continue;
    }

    final group = <Note>[current];
    var last = current;
    var j = i + 1;
    while (j < notes.length) {
      final candidate = notes[j];
      if (candidate.isTextNote) break;
      if (candidate.createdAt.difference(last.createdAt) <= groupWindow) {
        group.add(candidate);
        last = candidate;
        j += 1;
      } else {
        break;
      }
    }

    if (group.length > 1) {
      entries.add(
        _SessionEntry(
          photoGroup: PhotoGroup(
            subject: session.subject,
            timestamp: group.first.createdAt,
            photos: group,
          ),
        ),
      );
      i = j;
      continue;
    }

    entries.add(_SessionEntry(item: _toTimelineItem(current)));
    i += 1;
  }

  return entries;
}

TimelineItem _toTimelineItem(Note note) {
  return TimelineItem(
    noteId: note.id,
    createdAt: note.createdAt,
    timeLabel: DateFormat('HH:mm').format(note.createdAt),
    imagePath: note.imagePath,
    snippet: _snippetText(note.textContent ?? note.ocrText),
    isTextNote: note.isTextNote,
    source: note,
  );
}

String? _snippetText(String? text) {
  if (text == null) return null;
  final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.isEmpty) return null;
  if (compact.length <= 120) return compact;
  return '${compact.substring(0, 120)}...';
}

class _TimelineNodeTile extends StatelessWidget {
  final TimelineItem item;
  final bool isLast;
  final ValueChanged<Note>? onTap;

  const _TimelineNodeTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null ? null : () => onTap!(item.source),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.timeLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 90,
                      color: cs.outlineVariant,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imagePath != null &&
                        item.imagePath!.trim().isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.imagePath!),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: cs.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: cs.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ] else ...[
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.note_alt_outlined,
                          color: cs.outlineVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        item.snippet ?? 'No text available.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGroupTile extends StatelessWidget {
  final PhotoGroup group;
  final bool isLast;
  final ValueChanged<Note>? onNoteTap;

  const _PhotoGroupTile({
    required this.group,
    required this.isLast,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = group.photos.length;
    final label = DateFormat('HH:mm').format(group.timestamp);
    final cover = group.photos.first.imagePath;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showGroupSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 90,
                      color: cs.outlineVariant,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(cover),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 72,
                                height: 72,
                                color: cs.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: cs.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: cs.outlineVariant,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Explanation group\n$count photos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGroupSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: group.photos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final note = group.photos[index];
            final label = DateFormat('HH:mm').format(note.createdAt);
            final imagePath = note.imagePath;
            return ListTile(
              leading: imagePath != null && imagePath.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.photo_outlined,
                        color: cs.outlineVariant,
                      ),
                    ),
              title: Text('Photo $label'),
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

class _ProcessingNodeTile extends StatelessWidget {
  final ProcessingNote note;

  const _ProcessingNodeTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeLabel = DateFormat('HH:mm').format(note.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                timeLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: note.failed ? cs.error : cs.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 90,
                  color: cs.outlineVariant,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(note.imagePath),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: cs.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.failed ? 'OCR processing failed' : 'Processing OCR...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        if (!note.failed)
                          const LinearProgressIndicator(minHeight: 3)
                        else
                          Text(
                            'You can retake this photo from Camera.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
