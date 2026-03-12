import '../../notes/models/processing_note.dart';
import 'timeline_item.dart';

/// A date/session group in the class timeline.
class TimelineGroup {
  final DateTime date;
  final String dateLabel;
  final List<TimelineItem> items;
  final List<ProcessingNote> processingItems;

  const TimelineGroup({
    required this.date,
    required this.dateLabel,
    required this.items,
    this.processingItems = const [],
  });
}
