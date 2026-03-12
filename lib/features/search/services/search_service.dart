import '../../notes/models/note.dart';

/// Search strategy for OCR text queries.
class SearchService {
  /// Case-insensitive full-text search over OCR and manual text.
  List<Note> searchByOcrText(List<Note> notes, String query) {
    if (query.isEmpty) return const [];
    final q = query.toLowerCase();
    return notes
        .where((n) {
          final ocr = n.ocrText?.toLowerCase();
          final manual = n.textContent?.toLowerCase();
          return (ocr != null && ocr.contains(q)) ||
              (manual != null && manual.contains(q));
        })
        .toList();
  }
}
