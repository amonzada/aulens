import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aulens'**
  String get appName;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get navCamera;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @permissionNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission needed'**
  String get permissionNeededTitle;

  /// No description provided for @permissionNeededMessage.
  ///
  /// In en, this message translates to:
  /// **'We need camera and media permissions to capture whiteboard photos and store your class notes.'**
  String get permissionNeededMessage;

  /// No description provided for @permissionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get permissionTryAgain;

  /// No description provided for @permissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionNotNow;

  /// No description provided for @permissionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable permissions in Settings'**
  String get permissionSettingsTitle;

  /// No description provided for @permissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera or media permission is permanently denied. Open app settings to allow access and continue capturing whiteboards.'**
  String get permissionSettingsMessage;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permissionOpenSettings;

  /// No description provided for @permissionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get permissionCancel;

  /// No description provided for @cameraUnableOpen.
  ///
  /// In en, this message translates to:
  /// **'Unable to open camera right now.'**
  String get cameraUnableOpen;

  /// No description provided for @cameraSelectSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject first.'**
  String get cameraSelectSubjectFirst;

  /// No description provided for @cameraNoImageToSave.
  ///
  /// In en, this message translates to:
  /// **'No captured image to save.'**
  String get cameraNoImageToSave;

  /// No description provided for @cameraSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note. Please try again.'**
  String get cameraSaveFailed;

  /// No description provided for @cameraProcessingOcr.
  ///
  /// In en, this message translates to:
  /// **'Processing OCR in background...'**
  String get cameraProcessingOcr;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraTitle;

  /// No description provided for @cameraCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture a whiteboard'**
  String get cameraCaptureTitle;

  /// No description provided for @cameraCaptureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app will detect your current class\nand extract the text automatically.'**
  String get cameraCaptureSubtitle;

  /// No description provided for @cameraAnalysingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get cameraAnalysingImage;

  /// No description provided for @cameraAutoDetected.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected: {subject}'**
  String cameraAutoDetected(String subject);

  /// No description provided for @cameraNoClassScheduled.
  ///
  /// In en, this message translates to:
  /// **'No class currently scheduled'**
  String get cameraNoClassScheduled;

  /// No description provided for @cameraNoSubjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No subjects found. Add subjects in the Schedule tab first.'**
  String get cameraNoSubjectsFound;

  /// No description provided for @cameraSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get cameraSubjectLabel;

  /// No description provided for @cameraOcrLabel.
  ///
  /// In en, this message translates to:
  /// **'OCR'**
  String get cameraOcrLabel;

  /// No description provided for @cameraOcrHint.
  ///
  /// In en, this message translates to:
  /// **'Text extraction runs in the background after you tap Save.'**
  String get cameraOcrHint;

  /// No description provided for @cameraDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get cameraDiscard;

  /// No description provided for @cameraSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get cameraSaving;

  /// No description provided for @cameraSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get cameraSaveNote;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Capture whiteboard photos from the Camera tab\nto start building your collection.'**
  String get notesEmptyBody;

  /// No description provided for @noteTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTitleFallback;

  /// No description provided for @noteDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get noteDeleteTooltip;

  /// No description provided for @noteExtractedText.
  ///
  /// In en, this message translates to:
  /// **'Extracted Text'**
  String get noteExtractedText;

  /// No description provided for @noteNoTextExtracted.
  ///
  /// In en, this message translates to:
  /// **'No text was extracted from this image.'**
  String get noteNoTextExtracted;

  /// No description provided for @noteDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get noteDeleteDialogTitle;

  /// No description provided for @noteDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This note and its image file will be permanently deleted.'**
  String get noteDeleteDialogMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTitle;

  /// No description provided for @scheduleAddSubject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get scheduleAddSubject;

  /// No description provided for @scheduleDeleteSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subject'**
  String get scheduleDeleteSubjectTitle;

  /// No description provided for @scheduleDeleteSubjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{subject}\" and all its schedule entries?\nAssociated notes will also be removed.'**
  String scheduleDeleteSubjectMessage(String subject);

  /// No description provided for @scheduleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get scheduleEmptyTitle;

  /// No description provided for @scheduleEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first subject and set up its weekly schedule.'**
  String get scheduleEmptyBody;

  /// No description provided for @scheduleDeleteSubjectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete subject'**
  String get scheduleDeleteSubjectTooltip;

  /// No description provided for @scheduleNoScheduleAdded.
  ///
  /// In en, this message translates to:
  /// **'No schedule added.'**
  String get scheduleNoScheduleAdded;

  /// No description provided for @scheduleAddSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get scheduleAddSchedule;

  /// No description provided for @addSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'New Subject'**
  String get addSubjectTitle;

  /// No description provided for @addSubjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get addSubjectNameLabel;

  /// No description provided for @addSubjectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Mathematics'**
  String get addSubjectNameHint;

  /// No description provided for @addSubjectNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get addSubjectNameEmpty;

  /// No description provided for @addSubjectSave.
  ///
  /// In en, this message translates to:
  /// **'Save Subject'**
  String get addSubjectSave;

  /// No description provided for @addScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule - {subject}'**
  String addScheduleTitle(String subject);

  /// No description provided for @addScheduleDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of the week'**
  String get addScheduleDayOfWeek;

  /// No description provided for @addScheduleTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time slot'**
  String get addScheduleTimeSlot;

  /// No description provided for @addScheduleStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get addScheduleStart;

  /// No description provided for @addScheduleEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get addScheduleEnd;

  /// No description provided for @addScheduleSave.
  ///
  /// In en, this message translates to:
  /// **'Save Schedule'**
  String get addScheduleSave;

  /// No description provided for @addScheduleEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get addScheduleEndAfterStart;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in extracted text...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type to search your notes'**
  String get searchPrompt;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 items} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @timelineNoTextExtracted.
  ///
  /// In en, this message translates to:
  /// **'No text extracted.'**
  String get timelineNoTextExtracted;

  /// No description provided for @timelineOcrFailed.
  ///
  /// In en, this message translates to:
  /// **'OCR processing failed'**
  String get timelineOcrFailed;

  /// No description provided for @timelineOcrProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing OCR...'**
  String get timelineOcrProcessing;

  /// No description provided for @timelineRetakeHint.
  ///
  /// In en, this message translates to:
  /// **'You can retake this photo from Camera.'**
  String get timelineRetakeHint;

  /// No description provided for @timelineNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes for this class yet. Tap the camera to start.'**
  String get timelineNoNotes;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @pdfTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String pdfTimeLabel(String time);

  /// No description provided for @pdfOcrLabel.
  ///
  /// In en, this message translates to:
  /// **'OCR Text'**
  String get pdfOcrLabel;

  /// No description provided for @pdfNoText.
  ///
  /// In en, this message translates to:
  /// **'No extracted text.'**
  String get pdfNoText;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Aulens - Class Timeline Export'**
  String get pdfTitle;

  /// No description provided for @pdfSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject: {subject}'**
  String pdfSubjectLabel(String subject);

  /// No description provided for @pdfGeneratedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Generated at: {timestamp}'**
  String pdfGeneratedAtLabel(String timestamp);

  /// No description provided for @pdfNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes available for export.'**
  String get pdfNoNotes;

  /// No description provided for @pdfImageOutsideStorage.
  ///
  /// In en, this message translates to:
  /// **'Image path is outside managed storage'**
  String get pdfImageOutsideStorage;

  /// No description provided for @pdfImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get pdfImageNotFound;

  /// No description provided for @pdfImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get pdfImageLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
