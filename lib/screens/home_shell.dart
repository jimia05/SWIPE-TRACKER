import 'package:flutter/material.dart';

import 'history_screen.dart';
import 'home_screen.dart';
import 'plan_catalog_screen.dart';

/// Bottom-nav container for the three main tabs: Home, History, Plans.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [HomeScreen(), HistoryScreen(), PlanCatalogScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Plans',
          ),
        ],
      ),
    );
  }
}
