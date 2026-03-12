import '../../schedule/models/subject.dart';
import '../../schedule/models/schedule_entry.dart';
import '../../notes/models/note.dart';
import '../../notes/models/processing_note.dart';

/// Aggregates notes and photos that belong to a single class session.
class ClassSession {
  final Subject subject;
  final DateTime date;
  final ScheduleEntry? scheduleEntry;
  final List<Note> notes;
  final List<ProcessingNote> processingNotes;
  final bool isUnscheduled;

  const ClassSession({
    required this.subject,
    required this.date,
    required this.scheduleEntry,
    required this.notes,
    required this.processingNotes,
    this.isUnscheduled = false,
  });

  String? get startTime => scheduleEntry?.startTime;
  String? get endTime => scheduleEntry?.endTime;
}
