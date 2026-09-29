/// Who a plan is offered to. A plan can be available to more than one group.
enum StudentGroup {
  residenceHall('Residence Hall Students'),
  apartment('Apartment Students'),
  commuter('Commuter Students');

  const StudentGroup(this.label);
  final String label;
}

/// A single dining plan offering (e.g. the UIndy "19 Meal Plan").
///
/// Instances are immutable and come from a hardcoded catalog for now
/// ([MealPlanCatalog]); the fields here are deliberately generic (not
/// UIndy-specific) so a future catalog could be swapped in per school.
class MealPlan {
  const MealPlan({
    required this.id,
    required this.name,
    required this.mealsPerWeek,
    required this.flexDollarsPerSemester,
    required this.costPerSemester,
    required this.maxSwipesPerDay,
    required this.maxRetailSwipesPerDay,
    required this.availableTo,
    this.availabilityNote,
  });

  /// Stable identifier, persisted in local storage to remember the
  /// student's current selection.
  final String id;

  final String name;
  final int mealsPerWeek;
  final double flexDollarsPerSemester;
  final double costPerSemester;

  /// Total meal swipes (dining hall + retail combined) allowed per day.
  final int maxSwipesPerDay;

  /// Of the swipes above, at most this many may be used at retail spots
  /// (e.g. the PERK, Streets Grill) per day.
  final int maxRetailSwipesPerDay;

  final List<StudentGroup> availableTo;

  /// Qualifier on eligibility that doesn't fit [availableTo] cleanly, e.g.
  /// "Upperclassmen in Residence Halls" for a plan restricted by class year.
  final String? availabilityNote;
}
