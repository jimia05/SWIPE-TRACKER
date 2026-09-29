import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_tracker/data/meal_plans_catalog.dart';
import 'package:swipe_tracker/models/swipe_entry.dart';
import 'package:swipe_tracker/state/tracker_provider.dart';

import '../fakes/in_memory_tracker_store.dart';

void main() {
  late TrackerProvider tracker;

  setUp(() async {
    tracker = TrackerProvider(store: InMemoryTrackerStore());
    await tracker.load();
  });

  test('no plan selected by default', () {
    expect(tracker.selectedPlan, isNull);
    expect(tracker.mealsRemainingThisWeek, 0);
  });

  test('selecting a plan starts the semester and sets weekly allowance', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_4'));

    expect(tracker.selectedPlan?.id, 'plan_4');
    expect(tracker.mealsRemainingThisWeek, 4);
    expect(tracker.flexDollarsRemaining, 175);
    expect(tracker.semesterStartedAt, isNotNull);
  });

  test('logging a meal swipe decrements weekly and daily remaining', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_4'));

    await tracker.logMealSwipe(SwipeLocation.diningHall);

    expect(tracker.mealsRemainingThisWeek, 3);
    expect(tracker.swipesRemainingToday, 4);
    expect(tracker.entries, hasLength(1));
  });

  test('enforces the daily swipe cap even with weekly meals left', () async {
    // 4 Meal Plan: 5 swipes/day cap, 4 meals/week — cap won't bind here,
    // so use the 19 Meal Plan (6/day cap) and burn the daily cap directly.
    await tracker.selectPlan(MealPlanCatalog.byId('plan_19'));

    for (var i = 0; i < 6; i++) {
      await tracker.logMealSwipe(SwipeLocation.diningHall);
    }

    expect(tracker.swipesRemainingToday, 0);
    expect(
      () => tracker.logMealSwipe(SwipeLocation.diningHall),
      throwsA(isA<TrackerException>()),
    );
    // Weekly count still has room (19 - 6 = 13) but the daily cap blocks it.
    expect(tracker.mealsRemainingThisWeek, 13);
  });

  test('enforces the retail sub-cap independent of the daily total', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_19'));

    for (var i = 0; i < 3; i++) {
      await tracker.logMealSwipe(SwipeLocation.retail);
    }

    expect(tracker.retailSwipesRemainingToday, 0);
    expect(
      () => tracker.logMealSwipe(SwipeLocation.retail),
      throwsA(isA<TrackerException>()),
    );
    // Dining hall swipes should still work since only retail is capped.
    await tracker.logMealSwipe(SwipeLocation.diningHall);
    expect(tracker.swipesUsedToday, 4);
  });

  test('logging flex dollars decrements the semester balance', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_12'));

    await tracker.logFlexDollarSpend(20);
    await tracker.logFlexDollarSpend(5.50);

    expect(tracker.flexDollarsRemaining, closeTo(374.50, 0.001));
  });

  test('rejects a flex dollar spend beyond the remaining balance', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_4'));

    expect(
      () => tracker.logFlexDollarSpend(999),
      throwsA(isA<TrackerException>()),
    );
  });

  test('deleting an entry restores the balance it consumed', () async {
    await tracker.selectPlan(MealPlanCatalog.byId('plan_4'));
    await tracker.logMealSwipe(SwipeLocation.diningHall);
    final entry = tracker.entries.single;

    await tracker.deleteEntry(entry);

    expect(tracker.entries, isEmpty);
    expect(tracker.mealsRemainingThisWeek, 4);
  });
}
