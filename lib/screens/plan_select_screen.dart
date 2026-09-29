import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal_plan.dart';
import '../state/tracker_provider.dart';
import '../widgets/plan_card.dart';

class PlanSelectScreen extends StatelessWidget {
  const PlanSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Meal Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pick the plan you\'re on this semester. You can switch later '
            'from the Plans tab.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final plan in tracker.availablePlans) ...[
            PlanCard(
              plan: plan,
              onTap: () => _selectPlan(context, plan),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, MealPlan plan) async {
    await context.read<TrackerProvider>().selectPlan(plan);
  }
}
