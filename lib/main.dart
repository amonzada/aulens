import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/camera/pages/camera_page.dart';
import 'features/camera/services/camera_service.dart';
import 'features/class_mode/pages/class_mode_page.dart';
import 'features/notes/pages/notes_page.dart';
import 'features/notes/services/notes_service.dart';
import 'features/schedule/pages/schedule_page.dart';
import 'features/schedule/services/schedule_service.dart';
import 'features/schedule/models/subject.dart';
import 'features/schedule/models/schedule_entry.dart';
import 'features/search/pages/search_page.dart';
import 'features/search/services/search_service.dart';
import 'l10n/app_localizations.dart';
import 'shared/services/settings_service.dart';
import 'shared/database/database_service.dart';
import 'shared/providers/class_mode_controller.dart';
import 'shared/providers/notes_provider.dart';
import 'shared/providers/schedule_provider.dart';
import 'shared/providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AulensApp());
}

class AulensApp extends StatelessWidget {
  const AulensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<ScheduleService>(
          create: (context) => ScheduleService(context.read<DatabaseService>()),
        ),
        Provider<NotesService>(
          create: (context) => NotesService(context.read<DatabaseService>()),
        ),
        Provider<SearchService>(create: (_) => SearchService()),
        Provider<SettingsService>(create: (_) => SettingsService()),
        ChangeNotifierProvider(
          create: (context) => ScheduleProvider(context.read<ScheduleService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SettingsProvider(context.read<SettingsService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NotesProvider(
            context.read<NotesService>(),
            context.read<SearchService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ClassModeController()),
      ],
      child: MaterialApp(
        title: 'Aulens',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ── Main shell with bottom navigation ────────────────────────────────────────

class _MainScreen extends StatefulWidget {
  const _MainScreen();

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  int _index = 0;
  Timer? _classModeTimer;
  bool _classModeCheckInProgress = false;

  // Kept in an IndexedStack so each tab preserves its scroll / state.
  static const List<Widget> _pages = [
    SchedulePage(),
    CameraPage(),
    NotesPage(),
    SearchPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CameraService.instance.preload();
      _checkClassMode();
      _classModeTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _checkClassMode(),
      );
    });
  }

  @override
  void dispose() {
    _classModeTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkClassMode() async {
    if (!mounted) return;
    if (_classModeCheckInProgress) return;
    _classModeCheckInProgress = true;
    final scheduleProvider = context.read<ScheduleProvider>();
    final classMode = context.read<ClassModeController>();
    final settings = context.read<SettingsProvider>();
    final entry = scheduleProvider.getCurrentClass(
      preGraceMinutes: settings.preGraceMinutes,
      postGraceMinutes: settings.postGraceMinutes,
    );

    if (entry == null) {
      if (classMode.isOpen) {
        await Navigator.of(context, rootNavigator: true).maybePop();
      }
      classMode.clearDismissed();
      _classModeCheckInProgress = false;
      return;
    }

    final subject = scheduleProvider.subjectById(entry.subjectId);
    if (subject == null) {
      _classModeCheckInProgress = false;
      return;
    }

    if (!classMode.isOpen && !classMode.dismissed) {
      await _openClassMode(subject, entry, manual: false);
    }
    _classModeCheckInProgress = false;
  }

  Future<void> _openClassMode(
    Subject subject,
    ScheduleEntry entry, {
    required bool manual,
  }) async {
    final classMode = context.read<ClassModeController>();
    if (classMode.isOpen) return;

    if (manual) {
      classMode.clearDismissed();
    }

    classMode.setOpen(true);
    final subjects = context.read<ScheduleProvider>().subjects.toList();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ClassModePage(
          detectedSubject: subject,
          scheduleEntry: entry,
          subjects: subjects,
        ),
      ),
    );
    classMode.setOpen(false);
    classMode.markDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'main_camera_fab',
        tooltip: 'Open camera',
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        onPressed: () => setState(() => _index = 1),
        child: const Icon(Icons.camera_alt, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
