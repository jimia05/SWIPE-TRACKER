import '../models/meal_plan.dart';

/// Hardcoded 2026-2027 UIndy meal plan catalog.
///
/// This is intentionally a flat, static list rather than something loaded
/// from a file or server. If plans ever need to vary by school or year,
/// swap this out for a loader that returns `List<MealPlan>` — nothing else
/// in the app depends on how the catalog is produced.
class MealPlanCatalog {
  MealPlanCatalog._();

  static const List<MealPlan> plans = [
    MealPlan(
      id: 'plan_19',
      name: '19 Meal Plan',
      mealsPerWeek: 19,
      flexDollarsPerSemester: 550,
      costPerSemester: 3890,
      maxSwipesPerDay: 6,
      maxRetailSwipesPerDay: 3,
      availableTo: [
        StudentGroup.residenceHall,
        StudentGroup.apartment,
        StudentGroup.commuter,
      ],
    ),
    MealPlan(
      id: 'plan_12',
      name: '12 Meal Plan',
      mealsPerWeek: 12,
      flexDollarsPerSemester: 400,
      costPerSemester: 3140,
      maxSwipesPerDay: 6,
      maxRetailSwipesPerDay: 3,
      availableTo: [
        StudentGroup.residenceHall,
        StudentGroup.apartment,
        StudentGroup.commuter,
      ],
    ),
    MealPlan(
      id: 'plan_8',
      name: '8 Meal Plan',
      mealsPerWeek: 8,
      flexDollarsPerSemester: 350,
      costPerSemester: 2250,
      maxSwipesPerDay: 6,
      maxRetailSwipesPerDay: 3,
      availableTo: [
        StudentGroup.residenceHall,
        StudentGroup.apartment,
        StudentGroup.commuter,
      ],
      availabilityNote: 'Upperclassmen in Residence Halls',
    ),
    MealPlan(
      id: 'plan_4',
      name: '4 Meal Plan',
      mealsPerWeek: 4,
      flexDollarsPerSemester: 175,
      costPerSemester: 1140,
      maxSwipesPerDay: 5,
      maxRetailSwipesPerDay: 3,
      availableTo: [StudentGroup.apartment, StudentGroup.commuter],
    ),
  ];

  static MealPlan byId(String id) => plans.firstWhere((p) => p.id == id);
}
