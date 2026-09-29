import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tracker_provider.dart';
import 'home_shell.dart';
import 'plan_select_screen.dart';

/// Decides whether to show plan selection (no plan chosen yet) or the
/// main app shell, once the tracker has finished loading from disk.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();

    if (tracker.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tracker.selectedPlan == null) {
      return const PlanSelectScreen();
    }

    return const HomeShell();
  }
}
