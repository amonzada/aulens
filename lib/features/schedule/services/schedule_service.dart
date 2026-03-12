import '../../../shared/database/database_service.dart';
import '../models/schedule_entry.dart';
import '../models/subject.dart';

/// Domain service for schedule-related operations.
///
/// Encapsulates persistence logic for subjects and weekly schedule entries.
class ScheduleService {
  final DatabaseService _db;

  ScheduleService(this._db);

  Future<List<Subject>> getSubjects() => _db.getSubjects();

  Future<List<ScheduleEntry>> getScheduleEntries() => _db.getScheduleEntries();

  Future<int> createSubject(String name) {
    return _db.insertSubject(Subject(name: name.trim()));
  }

  Future<int> deleteSubject(int subjectId) => _db.deleteSubject(subjectId);

  Future<int> createScheduleEntry(ScheduleEntry entry) {
    return _db.insertScheduleEntry(entry);
  }

  Future<int> deleteScheduleEntry(int id) => _db.deleteScheduleEntry(id);
}
