// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aulens';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navCamera => 'Camera';

  @override
  String get navNotes => 'Notes';

  @override
  String get navSearch => 'Search';

  @override
  String get permissionNeededTitle => 'Permission needed';

  @override
  String get permissionNeededMessage =>
      'We need camera and media permissions to capture whiteboard photos and store your class notes.';

  @override
  String get permissionTryAgain => 'Try again';

  @override
  String get permissionNotNow => 'Not now';

  @override
  String get permissionSettingsTitle => 'Enable permissions in Settings';

  @override
  String get permissionSettingsMessage =>
      'Camera or media permission is permanently denied. Open app settings to allow access and continue capturing whiteboards.';

  @override
  String get permissionOpenSettings => 'Open Settings';

  @override
  String get permissionCancel => 'Cancel';

  @override
  String get cameraUnableOpen => 'Unable to open camera right now.';

  @override
  String get cameraSelectSubjectFirst => 'Please select a subject first.';

  @override
  String get cameraNoImageToSave => 'No captured image to save.';

  @override
  String get cameraSaveFailed => 'Failed to save note. Please try again.';

  @override
  String get cameraProcessingOcr => 'Processing OCR in background...';

  @override
  String get cameraTitle => 'Camera';

  @override
  String get cameraCaptureTitle => 'Capture a whiteboard';

  @override
  String get cameraCaptureSubtitle =>
      'The app will detect your current class\nand extract the text automatically.';

  @override
  String get cameraAnalysingImage => 'Analyzing image...';

  @override
  String cameraAutoDetected(String subject) {
    return 'Auto-detected: $subject';
  }

  @override
  String get cameraNoClassScheduled => 'No class currently scheduled';

  @override
  String get cameraNoSubjectsFound =>
      'No subjects found. Add subjects in the Schedule tab first.';

  @override
  String get cameraSubjectLabel => 'Subject';

  @override
  String get cameraOcrLabel => 'OCR';

  @override
  String get cameraOcrHint =>
      'Text extraction runs in the background after you tap Save.';

  @override
  String get cameraDiscard => 'Discard';

  @override
  String get cameraSaving => 'Saving...';

  @override
  String get cameraSaveNote => 'Save Note';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyBody =>
      'Capture whiteboard photos from the Camera tab\nto start building your collection.';

  @override
  String get noteTitleFallback => 'Note';

  @override
  String get noteDeleteTooltip => 'Delete note';

  @override
  String get noteExtractedText => 'Extracted Text';

  @override
  String get noteNoTextExtracted => 'No text was extracted from this image.';

  @override
  String get noteDeleteDialogTitle => 'Delete Note';

  @override
  String get noteDeleteDialogMessage =>
      'This note and its image file will be permanently deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get scheduleAddSubject => 'Add Subject';

  @override
  String get scheduleDeleteSubjectTitle => 'Delete Subject';

  @override
  String scheduleDeleteSubjectMessage(String subject) {
    return 'Delete \"$subject\" and all its schedule entries?\nAssociated notes will also be removed.';
  }

  @override
  String get scheduleEmptyTitle => 'No subjects yet';

  @override
  String get scheduleEmptyBody =>
      'Add your first subject and set up its weekly schedule.';

  @override
  String get scheduleDeleteSubjectTooltip => 'Delete subject';

  @override
  String get scheduleNoScheduleAdded => 'No schedule added.';

  @override
  String get scheduleAddSchedule => 'Add Schedule';

  @override
  String get addSubjectTitle => 'New Subject';

  @override
  String get addSubjectNameLabel => 'Subject name';

  @override
  String get addSubjectNameHint => 'e.g., Mathematics';

  @override
  String get addSubjectNameEmpty => 'Name cannot be empty';

  @override
  String get addSubjectSave => 'Save Subject';

  @override
  String addScheduleTitle(String subject) {
    return 'Schedule - $subject';
  }

  @override
  String get addScheduleDayOfWeek => 'Day of the week';

  @override
  String get addScheduleTimeSlot => 'Time slot';

  @override
  String get addScheduleStart => 'Start';

  @override
  String get addScheduleEnd => 'End';

  @override
  String get addScheduleSave => 'Save Schedule';

  @override
  String get addScheduleEndAfterStart => 'End time must be after start time.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search in extracted text...';

  @override
  String get searchPrompt => 'Type to search your notes';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: '0 items',
    );
    return '$_temp0';
  }

  @override
  String get timelineNoTextExtracted => 'No text extracted.';

  @override
  String get timelineOcrFailed => 'OCR processing failed';

  @override
  String get timelineOcrProcessing => 'Processing OCR...';

  @override
  String get timelineRetakeHint => 'You can retake this photo from Camera.';

  @override
  String get timelineNoNotes =>
      'No notes for this class yet. Tap the camera to start.';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String pdfTimeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String get pdfOcrLabel => 'OCR Text';

  @override
  String get pdfNoText => 'No extracted text.';

  @override
  String get pdfTitle => 'Aulens - Class Timeline Export';

  @override
  String pdfSubjectLabel(String subject) {
    return 'Subject: $subject';
  }

  @override
  String pdfGeneratedAtLabel(String timestamp) {
    return 'Generated at: $timestamp';
  }

  @override
  String get pdfNoNotes => 'No notes available for export.';

  @override
  String get pdfImageOutsideStorage => 'Image path is outside managed storage';

  @override
  String get pdfImageNotFound => 'Image not found';

  @override
  String get pdfImageLoadFailed => 'Failed to load image';
}
