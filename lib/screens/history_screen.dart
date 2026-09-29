import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/swipe_entry.dart';
import '../state/tracker_provider.dart';
import '../widgets/entry_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final entries = tracker.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'No activity logged yet.',
                style: TextStyle(color: AppColors.gray),
              ),
            )
          : ListView(
              children: _groupByDay(entries).entries.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        group.key,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              color: AppColors.gray,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    for (final entry in group.value)
                      Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            context.read<TrackerProvider>().deleteEntry(entry),
                        child: EntryTile(
                          entry: entry,
                          onDelete: () =>
                              context.read<TrackerProvider>().deleteEntry(entry),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Map<String, List<SwipeEntry>> _groupByDay(List<SwipeEntry> entries) {
    final grouped = <String, List<SwipeEntry>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final entry in entries) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == today.subtract(const Duration(days: 1))) {
        label = 'Yesterday';
      } else {
        label = DateFormat('EEEE, MMM d').format(day);
      }
      grouped.putIfAbsent(label, () => []).add(entry);
    }
    return grouped;
  }
}
