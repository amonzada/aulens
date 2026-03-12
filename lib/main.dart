import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/camera/pages/camera_page.dart';
import 'features/notes/pages/notes_page.dart';
import 'features/notes/services/notes_service.dart';
import 'features/schedule/pages/schedule_page.dart';
import 'features/schedule/services/schedule_service.dart';
import 'features/search/pages/search_page.dart';
import 'features/search/services/search_service.dart';
import 'shared/database/database_service.dart';
import 'shared/providers/notes_provider.dart';
import 'shared/providers/schedule_provider.dart';

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
        ChangeNotifierProvider(
          create: (context) => ScheduleProvider(context.read<ScheduleService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NotesProvider(
            context.read<NotesService>(),
            context.read<SearchService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Aulens',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
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

  // Kept in an IndexedStack so each tab preserves its scroll / state.
  static const List<Widget> _pages = [
    SchedulePage(),
    CameraPage(),
    NotesPage(),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
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
