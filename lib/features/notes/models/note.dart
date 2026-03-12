/// A whiteboard photo note linked to a [Subject].
class Note {
  final int? id;
  final int subjectId;

  /// Absolute path to the image file stored in app documents directory.
  final String imagePath;

  /// Text extracted from the image via OCR. May be `null` if extraction
  /// failed or the image contained no readable text.
  final String? ocrText;

  final DateTime createdAt;

  const Note({
    this.id,
    required this.subjectId,
    required this.imagePath,
    this.ocrText,
    required this.createdAt,
  });

  Note copyWith({
    int? id,
    int? subjectId,
    String? imagePath,
    String? ocrText,
    DateTime? createdAt,
  }) =>
      Note(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        imagePath: imagePath ?? this.imagePath,
        ocrText: ocrText ?? this.ocrText,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Used for DB inserts – `id` is excluded as it is AUTOINCREMENT.
  Map<String, dynamic> toMap() => {
        'subject_id': subjectId,
        'image_path': imagePath,
        'ocr_text': ocrText,
        'created_at': createdAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as int,
        subjectId: m['subject_id'] as int,
        imagePath: m['image_path'] as String,
        ocrText: m['ocr_text'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  @override
  String toString() =>
      'Note(id: $id, subjectId: $subjectId, createdAt: $createdAt)';
}
