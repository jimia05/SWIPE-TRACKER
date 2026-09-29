import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/swipe_entry.dart';
import '../state/tracker_provider.dart';
import '../widgets/entry_tile.dart';
import '../widgets/stat_card.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final plan = tracker.selectedPlan!;
    final recent = tracker.entries.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: RefreshIndicator(
        onRefresh: tracker.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'MEALS THIS WEEK',
                    value:
                        '${tracker.mealsRemainingThisWeek} / ${plan.mealsPerWeek}',
                    subtitle:
                        'Resets ${DateFormat('EEE, MMM d').format(tracker.nextWeekReset)}',
                    progress: plan.mealsPerWeek == 0
                        ? 0
                        : tracker.mealsRemainingThisWeek / plan.mealsPerWeek,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'FLEX DOLLARS',
                    value:
                        '\$${tracker.flexDollarsRemaining.toStringAsFixed(0)}',
                    subtitle:
                        'of \$${plan.flexDollarsPerSemester.toStringAsFixed(0)} this semester',
                    progress: plan.flexDollarsPerSemester == 0
                        ? 0
                        : tracker.flexDollarsRemaining /
                              plan.flexDollarsPerSemester,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatCard(
              title: 'TODAY',
              value: '${tracker.swipesRemainingToday} swipes left',
              subtitle:
                  '${tracker.retailSwipesRemainingToday} of '
                  '${plan.maxRetailSwipesPerDay} retail swipes left today',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _logSwipe(context),
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Log Swipe'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _logFlexDollars(context),
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Log Flex \$'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No activity yet. Log your first swipe above.',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              )
            else
              ...recent.map((e) => EntryTile(entry: e)),
          ],
        ),
      ),
    );
  }

  Future<void> _logSwipe(BuildContext context) async {
    final tracker = context.read<TrackerProvider>();
    final location = await showModalBottomSheet<SwipeLocation>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Where are you swiping?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Dining Hall'),
              onTap: () =>
                  Navigator.pop(sheetContext, SwipeLocation.diningHall),
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Retail (PERK / Streets Grill)'),
              onTap: () => Navigator.pop(sheetContext, SwipeLocation.retail),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (location == null || !context.mounted) return;

    try {
      await tracker.logMealSwipe(location);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Swipe logged.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _logFlexDollars(BuildContext context) async {
    final tracker = context.read<TrackerProvider>();
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Flex Dollar Spend'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, double.tryParse(controller.text)),
            child: const Text('Log'),
          ),
        ],
      ),
    );

    if (amount == null || !context.mounted) return;

    try {
      await tracker.logFlexDollarSpend(amount);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Flex dollars logged.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
