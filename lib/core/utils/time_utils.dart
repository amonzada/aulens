import '../../features/schedule/models/schedule_entry.dart';

/// Time / date helpers used for automatic class-detection logic.
class TimeUtils {
  TimeUtils._();

  /// Formats [hour] and [minute] as a zero-padded "HH:mm" string.
  static String formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Returns the current wall-clock time as a "HH:mm" string.
  static String currentTimeString() {
    final now = DateTime.now();
    return formatTime(now.hour, now.minute);
  }

  /// Returns `true` when [time] falls in the closed interval [[start], [end]]
  /// (all values must be zero-padded "HH:mm" strings so lexicographic
  /// comparison is equivalent to numeric comparison).
  static bool isTimeBetween(String time, String start, String end) =>
      time.compareTo(start) >= 0 && time.compareTo(end) <= 0;

  /// Scans [entries] and returns the first one whose weekday matches today
  /// and whose time window contains the current time, or `null` if none.
  static ScheduleEntry? detectCurrentClass(List<ScheduleEntry> entries) {
    final now = DateTime.now();
    final time = formatTime(now.hour, now.minute);
    for (final e in entries) {
      if (e.weekday == now.weekday &&
          isTimeBetween(time, e.startTime, e.endTime)) {
        return e;
      }
    }
    return null;
  }

  /// Human-readable day name for a [DateTime.weekday] value (1 = Monday).
  static String weekdayName(int weekday) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][(weekday - 1).clamp(0, 6)];
}
