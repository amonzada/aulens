import '../../notes/models/note.dart';
import '../../schedule/models/subject.dart';

/// Groups photos captured within a short time window.
class PhotoGroup {
  final Subject subject;
  final DateTime timestamp;
  final List<Note> photos;

  const PhotoGroup({
    required this.subject,
    required this.timestamp,
    required this.photos,
  });
}
