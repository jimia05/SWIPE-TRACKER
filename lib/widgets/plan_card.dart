import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/meal_plan.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    this.selected = false,
    this.onTap,
  });

  final MealPlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? AppColors.crimson.withValues(alpha: 0.06)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.crimson : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle, color: AppColors.crimson),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${plan.mealsPerWeek} meals / week · up to '
                '${plan.maxSwipesPerDay}/day (${plan.maxRetailSwipesPerDay} '
                'retail max)',
              ),
              const SizedBox(height: 4),
              Text(
                '\$${plan.flexDollarsPerSemester.toStringAsFixed(0)} flex '
                'dollars / semester',
              ),
              const SizedBox(height: 8),
              Text(
                '\$${plan.costPerSemester.toStringAsFixed(0)} per semester',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.crimson),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.availableTo
                    .map(
                      (g) => Chip(
                        label: Text(g.label, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              if (plan.availabilityNote != null) ...[
                const SizedBox(height: 4),
                Text(
                  plan.availabilityNote!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
