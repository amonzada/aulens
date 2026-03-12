/// App-wide constants shared across all features.
class AppConstants {
  AppConstants._();

  static const String appName = 'Aulens';
  static const String dbName = 'aulens.db';
  static const int dbVersion = 1;

  /// Subdirectory inside application documents for persisted note images.
  static const String imagesDirName = 'aulens_images';

  /// Weekday names indexed by [DateTime.weekday] convention (1 = Monday … 7 = Sunday).
  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
