import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal_plan.dart';
import '../state/tracker_provider.dart';
import '../widgets/plan_card.dart';

class PlanCatalogScreen extends StatelessWidget {
  const PlanCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Start new semester',
            onPressed: () => _confirmNewSemester(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final plan in tracker.availablePlans) ...[
            PlanCard(
              plan: plan,
              selected: plan.id == tracker.selectedPlan?.id,
              onTap: () => _switchPlan(context, plan),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _switchPlan(BuildContext context, MealPlan plan) async {
    final tracker = context.read<TrackerProvider>();
    if (plan.id == tracker.selectedPlan?.id) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Switch Meal Plan?'),
        content: Text(
          'Switch to the ${plan.name}? Your weekly swipe and flex dollar '
          'limits will update immediately; past history is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await tracker.selectPlan(plan);
    }
  }

  Future<void> _confirmNewSemester(BuildContext context) async {
    final tracker = context.read<TrackerProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start New Semester?'),
        content: const Text(
          'This resets your flex dollar balance to full for the current '
          'plan. Past history stays in your log.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await tracker.startNewSemester();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New semester started.')),
        );
      }
    }
  }
}
