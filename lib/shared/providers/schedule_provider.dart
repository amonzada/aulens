import 'package:flutter/foundation.dart';

import '../../features/schedule/models/subject.dart';
import '../../features/schedule/models/schedule_entry.dart';
import '../../features/schedule/services/schedule_service.dart';
import '../../core/utils/time_utils.dart';

/// Manages subjects and weekly schedule entries.
///
/// Loads data eagerly from SQLite on construction and exposes mutating
/// methods that keep the in-memory list and the database in sync.
class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service;

  List<Subject> _subjects = [];
  List<ScheduleEntry> _entries = [];
  bool _loading = false;

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<ScheduleEntry> get entries => List.unmodifiable(_entries);
  bool get loading => _loading;

  bool _disposed = false;

  ScheduleProvider(this._service) {
    _load();
  }

  Future<void> _load() async {
    _loading = true;
    _safeNotify();
    _subjects = await _service.getSubjects();
    _entries = await _service.getScheduleEntries();
    _loading = false;
    _safeNotify();
  }

  // ── Subjects ───────────────────────────────────────────────────────────────

  Future<void> addSubject(String name) async {
    final trimmed = name.trim();
    final id = await _service.createSubject(trimmed);
    _subjects = [..._subjects, Subject(id: id, name: trimmed)];
    _safeNotify();
  }

  Future<void> deleteSubject(int id) async {
    await _service.deleteSubject(id); // cascade removes entries & notes in DB
    _subjects = _subjects.where((s) => s.id != id).toList();
    _entries = _entries.where((e) => e.subjectId != id).toList();
    _safeNotify();
  }

  // ── Schedule entries ───────────────────────────────────────────────────────

  Future<void> addScheduleEntry(ScheduleEntry entry) async {
    final id = await _service.createScheduleEntry(entry);
    _entries = [..._entries, entry.copyWith(id: id)];
    _safeNotify();
  }

  Future<void> deleteScheduleEntry(int id) async {
    await _service.deleteScheduleEntry(id);
    _entries = _entries.where((e) => e.id != id).toList();
    _safeNotify();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// All schedule entries that belong to [subjectId].
  List<ScheduleEntry> entriesForSubject(int subjectId) =>
      _entries.where((e) => e.subjectId == subjectId).toList();

  /// Returns the [Subject] with id == [subjectId], or `null` if not found.
  Subject? subjectById(int subjectId) {
    for (final s in _subjects) {
      if (s.id == subjectId) return s;
    }
    return null;
  }

  /// Returns the [ScheduleEntry] that is active right now (if any).
  ScheduleEntry? getCurrentClass() =>
      TimeUtils.detectCurrentClass(_entries);

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
