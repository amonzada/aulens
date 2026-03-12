import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../notes/models/note.dart';
import '../../notes/models/processing_note.dart';
import '../models/timeline_group.dart';
import '../models/timeline_item.dart';

/// Vertical chronological timeline grouped by class session date.
///
/// Expected input: notes from a single subject.
class ClassTimelineView extends StatelessWidget {
  final List<Note> notes;
  final List<ProcessingNote> processingNotes;
  final ValueChanged<Note>? onNoteTap;

  const ClassTimelineView({
    super.key,
    required this.notes,
    this.processingNotes = const [],
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups(notes, processingNotes);
    if (groups.isEmpty) {
      return const _EmptyClassNotes();
    }

    return Column(
      children: groups
          .map(
            (g) => _TimelineGroupSection(
              group: g,
              onNoteTap: onNoteTap,
            ),
          )
          .toList(),
    );
  }

  List<TimelineGroup> _buildGroups(
    List<Note> source,
    List<ProcessingNote> pending,
  ) {
    final byDay = <String, _FeedBucket>{};

    for (final note in source) {
      final key = DateFormat('yyyy-MM-dd').format(note.createdAt);
      byDay.putIfAbsent(key, () => _FeedBucket()).ready.add(note);
    }

    for (final note in pending) {
      final key = DateFormat('yyyy-MM-dd').format(note.createdAt);
      byDay.putIfAbsent(key, () => _FeedBucket()).processing.add(note);
    }

    final keys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((key) {
      final date = DateTime.parse(key);
      final bucket = byDay[key]!;

      final items = bucket.ready
          .map(
            (note) => TimelineItem(
              noteId: note.id,
              createdAt: note.createdAt,
              timeLabel: DateFormat('HH:mm').format(note.createdAt),
              imagePath: note.imagePath,
              ocrSnippet: _snippet(note.ocrText),
              source: note,
            ),
          )
          .toList();

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final processingItems = bucket.processing
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return TimelineGroup(
        date: date,
        dateLabel: DateFormat('EEE, MMM d, yyyy').format(date),
        items: items,
        processingItems: processingItems,
      );
    }).toList();
  }

  String? _snippet(String? text) {
    if (text == null) return null;
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return null;
    if (compact.length <= 120) return compact;
    return '${compact.substring(0, 120)}...';
  }
}

class _TimelineGroupSection extends StatelessWidget {
  final TimelineGroup group;
  final ValueChanged<Note>? onNoteTap;

  const _TimelineGroupSection({
    required this.group,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                group.dateLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${group.items.length + group.processingItems.length} item${group.items.length + group.processingItems.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...group.processingItems.map((p) => _ProcessingNodeTile(note: p)),
          ...List.generate(
            group.items.length,
            (index) => _TimelineNodeTile(
              item: group.items[index],
              isLast: index == group.items.length - 1,
              onTap: onNoteTap,
            ),
          ),
        ],
      ),
    );
  }
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(item.imagePath),
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
                    Expanded(
                      child: Text(
                        item.ocrSnippet ?? 'No text extracted.',
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

class _ProcessingNodeTile extends StatelessWidget {
  final ProcessingNote note;

  const _ProcessingNodeTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final timeLabel = DateFormat.Hm(l10n.localeName).format(note.createdAt);

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

class _FeedBucket {
  final List<Note> ready = <Note>[];
  final List<ProcessingNote> processing = <ProcessingNote>[];
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
              'No notes for this class yet. Tap the camera to start.',
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
