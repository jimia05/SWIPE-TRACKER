import 'package:flutter/foundation.dart';

import '../data/meal_plans_catalog.dart';
import '../models/meal_plan.dart';
import '../models/swipe_entry.dart';
import '../services/database_service.dart';
import '../services/tracker_store.dart';

class TrackerException implements Exception {
  TrackerException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// App-wide state for the currently selected plan and its usage.
///
/// All the meal-plan business rules (weekly reset, daily swipe caps, the
/// retail sub-cap, flex dollar balance) live here so screens stay thin.
class TrackerProvider extends ChangeNotifier {
  TrackerProvider({TrackerStore? store})
    : _db = store ?? DatabaseService.instance;

  final TrackerStore _db;

  static const _selectedPlanKey = 'selected_plan_id';
  static const _semesterStartKey = 'semester_started_at';

  MealPlan? _selectedPlan;
  DateTime? _semesterStartedAt;
  List<SwipeEntry> _entries = [];
  bool _loading = true;

  MealPlan? get selectedPlan => _selectedPlan;
  DateTime? get semesterStartedAt => _semesterStartedAt;
  bool get loading => _loading;
  List<SwipeEntry> get entries => List.unmodifiable(_entries);
  List<MealPlan> get availablePlans => MealPlanCatalog.plans;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final planId = await _db.getSetting(_selectedPlanKey);
    _selectedPlan = planId == null ? null : MealPlanCatalog.byId(planId);

    final semesterStartRaw = await _db.getSetting(_semesterStartKey);
    _semesterStartedAt = semesterStartRaw == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(int.parse(semesterStartRaw));

    _entries = await _db.allEntries();

    _loading = false;
    notifyListeners();
  }

  Future<void> selectPlan(MealPlan plan) async {
    await _db.setSetting(_selectedPlanKey, plan.id);
    _selectedPlan = plan;
    if (_semesterStartedAt == null) {
      await _startSemesterNow();
    }
    notifyListeners();
  }

  /// Resets the flex dollar balance to full and clears weekly swipe
  /// tracking going forward, without deleting past history. Intended for
  /// the start of a new semester.
  Future<void> startNewSemester() async {
    await _startSemesterNow();
    notifyListeners();
  }

  Future<void> _startSemesterNow() async {
    final now = DateTime.now();
    await _db.setSetting(
      _semesterStartKey,
      now.millisecondsSinceEpoch.toString(),
    );
    _semesterStartedAt = now;
  }

  // --- Time boundaries ---------------------------------------------------

  /// Midnight of the most recent Monday (the plan's weekly swipe reset).
  DateTime get currentWeekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceMonday = today.weekday - DateTime.monday;
    return today.subtract(Duration(days: daysSinceMonday));
  }

  DateTime get nextWeekReset => currentWeekStart.add(const Duration(days: 7));

  DateTime get todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // --- Derived usage -------------------------------------------------------

  List<SwipeEntry> get _mealSwipesThisWeek => _entries
      .where(
        (e) =>
            e.type == EntryType.mealSwipe &&
            e.timestamp.isAfter(currentWeekStart),
      )
      .toList();

  List<SwipeEntry> get _mealSwipesToday => _entries
      .where(
        (e) => e.type == EntryType.mealSwipe && e.timestamp.isAfter(todayStart),
      )
      .toList();

  int get mealsUsedThisWeek => _mealSwipesThisWeek.length;

  int get mealsRemainingThisWeek {
    final plan = _selectedPlan;
    if (plan == null) return 0;
    final remaining = plan.mealsPerWeek - mealsUsedThisWeek;
    return remaining < 0 ? 0 : remaining;
  }

  int get swipesUsedToday => _mealSwipesToday.length;

  int get retailSwipesUsedToday => _mealSwipesToday
      .where((e) => e.location == SwipeLocation.retail)
      .length;

  int get swipesRemainingToday {
    final plan = _selectedPlan;
    if (plan == null) return 0;
    final remaining = plan.maxSwipesPerDay - swipesUsedToday;
    return remaining < 0 ? 0 : remaining;
  }

  int get retailSwipesRemainingToday {
    final plan = _selectedPlan;
    if (plan == null) return 0;
    final remaining = plan.maxRetailSwipesPerDay - retailSwipesUsedToday;
    return remaining < 0 ? 0 : remaining;
  }

  double get flexDollarsSpent {
    final start = _semesterStartedAt;
    if (start == null) return 0;
    return _entries
        .where(
          (e) => e.type == EntryType.flexDollar && e.timestamp.isAfter(start),
        )
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
  }

  double get flexDollarsRemaining {
    final plan = _selectedPlan;
    if (plan == null) return 0;
    final remaining = plan.flexDollarsPerSemester - flexDollarsSpent;
    return remaining < 0 ? 0 : remaining;
  }

  // --- Mutations -----------------------------------------------------------

  Future<void> logMealSwipe(SwipeLocation location) async {
    final plan = _selectedPlan;
    if (plan == null) throw TrackerException('No meal plan selected.');

    if (mealsRemainingThisWeek <= 0) {
      throw TrackerException(
        "You've used all $mealsUsedThisWeek weekly swipes on the "
        '${plan.name}. It resets Monday.',
      );
    }
    if (swipesRemainingToday <= 0) {
      throw TrackerException(
        'Daily limit reached: ${plan.maxSwipesPerDay} swipes per day on '
        'the ${plan.name}.',
      );
    }
    if (location == SwipeLocation.retail && retailSwipesRemainingToday <= 0) {
      throw TrackerException(
        'Retail limit reached: at most ${plan.maxRetailSwipesPerDay} '
        'retail swipes per day.',
      );
    }

    final entry = await _db.insertEntry(
      SwipeEntry(
        type: EntryType.mealSwipe,
        timestamp: DateTime.now(),
        location: location,
      ),
    );
    _entries.insert(0, entry);
    notifyListeners();
  }

  Future<void> logFlexDollarSpend(double amount, {String? note}) async {
    final plan = _selectedPlan;
    if (plan == null) throw TrackerException('No meal plan selected.');
    if (amount <= 0) {
      throw TrackerException('Enter an amount greater than \$0.');
    }
    if (amount > flexDollarsRemaining) {
      throw TrackerException(
        'Only \$${flexDollarsRemaining.toStringAsFixed(2)} in flex '
        'dollars remaining this semester.',
      );
    }

    final entry = await _db.insertEntry(
      SwipeEntry(
        type: EntryType.flexDollar,
        timestamp: DateTime.now(),
        amount: amount,
        note: note,
      ),
    );
    _entries.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(SwipeEntry entry) async {
    if (entry.id == null) return;
    await _db.deleteEntry(entry.id!);
    _entries.removeWhere((e) => e.id == entry.id);
    notifyListeners();
  }
}
