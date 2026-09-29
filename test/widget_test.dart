import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swipe_tracker/main.dart';

import 'fakes/in_memory_tracker_store.dart';

void main() {
  testWidgets('shows plan selection when no plan is chosen yet', (
    tester,
  ) async {
    await tester.pumpWidget(SwipeTrackerApp(store: InMemoryTrackerStore()));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Meal Plan'), findsOneWidget);
    expect(find.text('19 Meal Plan'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('4 Meal Plan'),
      find.byType(Scrollable),
      const Offset(0, -200),
    );
    expect(find.text('4 Meal Plan'), findsOneWidget);
  });

  testWidgets('selecting a plan shows the home dashboard', (tester) async {
    await tester.pumpWidget(SwipeTrackerApp(store: InMemoryTrackerStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('12 Meal Plan'));
    await tester.pumpAndSettle();

    expect(find.text('MEALS THIS WEEK'), findsOneWidget);
    expect(find.text('FLEX DOLLARS'), findsOneWidget);
  });
}
