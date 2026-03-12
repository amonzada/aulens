import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../features/camera/services/camera_service.dart';
import '../../features/notes/models/note.dart';
import '../../features/notes/models/processing_note.dart';
import '../../features/notes/services/notes_service.dart';
import '../../features/search/services/search_service.dart';

/// Manages the in-memory list of notes and keeps it in sync with SQLite.
class NotesProvider extends ChangeNotifier {
  final NotesService _notesService;
  final SearchService _searchService;

  List<Note> _notes = [];
  final Map<String, ProcessingNote> _processingNotes = {};
  bool _loading = false;
  StreamSubscription<CameraTaskEvent>? _taskSub;

  List<Note> get notes => List.unmodifiable(_notes);
  List<ProcessingNote> get processingNotes =>
      List.unmodifiable(_processingNotes.values.toList());
  bool get loading => _loading;

  bool _disposed = false;

  NotesProvider(this._notesService, this._searchService) {
    _taskSub = CameraService.instance.taskEvents.listen(_onTaskEvent);
    _load();
  }

  Future<void> _load() async {
    _loading = true;
    _safeNotify();
    _notes = await _notesService.getNotes();
    _loading = false;
    _safeNotify();
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<Note> addNote({
    required int subjectId,
    required String imagePath,
    String? ocrText,
  }) async {
    final note = Note(
      subjectId: subjectId,
      imagePath: imagePath,
      ocrText: ocrText,
      createdAt: DateTime.now(),
    );
    final id = await _notesService.createNote(note);
    final saved = note.copyWith(id: id);
    _notes = [saved, ..._notes]; // newest first
    _safeNotify();
    return saved;
  }

  Future<void> deleteNote(int id) async {
    // Delete the image file from disk (best-effort).
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      await _notesService.deleteImageFile(_notes[idx].imagePath);
    }
    await _notesService.deleteNote(id);
    _notes = _notes.where((n) => n.id != id).toList();
    _safeNotify();
  }

  /// Removes all notes of a subject from memory after DB-level cascade delete.
  void removeNotesBySubject(int subjectId) {
    _notes = _notes.where((n) => n.subjectId != subjectId).toList();
    _safeNotify();
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Notes belonging to [subjectId], newest first.
  List<Note> notesForSubject(int subjectId) =>
      _notes.where((n) => n.subjectId == subjectId).toList();

  /// Background-processing notes belonging to [subjectId], newest first.
  List<ProcessingNote> processingNotesForSubject(int subjectId) {
    final list = _processingNotes.values
        .where((n) => n.subjectId == subjectId)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Case-insensitive full-text search over OCR text.
  /// Returns an empty list when [query] is blank.
  List<Note> searchNotes(String query) =>
      _searchService.searchByOcrText(_notes, query);

  void _onTaskEvent(CameraTaskEvent event) {
    switch (event.status) {
      case CameraTaskStatus.queued:
      case CameraTaskStatus.processingOcr:
      case CameraTaskStatus.savingNote:
        _processingNotes[event.taskId] = ProcessingNote(
          taskId: event.taskId,
          subjectId: event.subjectId,
          imagePath: event.imagePath,
          createdAt: event.createdAt,
          failed: false,
        );
        _safeNotify();
        return;
      case CameraTaskStatus.completed:
        _processingNotes.remove(event.taskId);
        _safeNotify();
        return;
      case CameraTaskStatus.failed:
        final current = _processingNotes[event.taskId];
        if (current != null) {
          _processingNotes[event.taskId] = current.copyWith(failed: true);
          _safeNotify();
        }
        return;
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _taskSub?.cancel();
    super.dispose();
  }
}
