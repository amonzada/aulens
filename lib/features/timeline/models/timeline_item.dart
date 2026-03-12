import '../../notes/models/note.dart';

/// A single visual item in the class timeline.
class TimelineItem {
  final int? noteId;
  final DateTime createdAt;
  final String timeLabel;
  final String imagePath;
  final String? ocrSnippet;
  final Note source;

  const TimelineItem({
    required this.noteId,
    required this.createdAt,
    required this.timeLabel,
    required this.imagePath,
    required this.ocrSnippet,
    required this.source,
  });
}
