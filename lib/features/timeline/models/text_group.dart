import '../../notes/models/note.dart';
import '../../schedule/models/subject.dart';

/// Groups text notes created within a short time window.
class TextGroup {
  final Subject subject;
  final DateTime timestamp;
  final List<Note> notes;

  const TextGroup({
    required this.subject,
    required this.timestamp,
    required this.notes,
  });
}
