/// Represents a note that is still being processed in the background.
class ProcessingNote {
  final String taskId;
  final int subjectId;
  final String imagePath;
  final DateTime createdAt;
  final bool failed;

  const ProcessingNote({
    required this.taskId,
    required this.subjectId,
    required this.imagePath,
    required this.createdAt,
    this.failed = false,
  });

  ProcessingNote copyWith({
    String? taskId,
    int? subjectId,
    String? imagePath,
    DateTime? createdAt,
    bool? failed,
  }) {
    return ProcessingNote(
      taskId: taskId ?? this.taskId,
      subjectId: subjectId ?? this.subjectId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      failed: failed ?? this.failed,
    );
  }
}
