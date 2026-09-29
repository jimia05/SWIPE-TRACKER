import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'screens/root_screen.dart';
import 'services/platform_db_init.dart';
import 'services/tracker_store.dart';
import 'state/tracker_provider.dart';

void main() {
  initializeDatabaseFactory();
  runApp(const SwipeTrackerApp());
}

class SwipeTrackerApp extends StatelessWidget {
  const SwipeTrackerApp({super.key, this.store});

  /// Overrides the default sqflite-backed store; used by tests to inject
  /// an in-memory [TrackerStore].
  final TrackerStore? store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackerProvider(store: store)..load(),
      child: MaterialApp(
        title: 'Swipe Tracker',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootScreen(),
      ),
    );
  }
}
