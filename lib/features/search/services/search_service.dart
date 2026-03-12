import '../../notes/models/note.dart';

/// Search strategy for OCR text queries.
class SearchService {
  /// Case-insensitive full-text search over OCR text.
  List<Note> searchByOcrText(List<Note> notes, String query) {
    if (query.isEmpty) return const [];
    final q = query.toLowerCase();
    return notes
        .where((n) => n.ocrText != null && n.ocrText!.toLowerCase().contains(q))
        .toList();
  }
}
