# SWIPE-TRACKER

A Flutter app for tracking UIndy meal plan swipes and flex dollars, with weekly
reset tracking, daily/retail swipe caps, and usage history.

## Plans

The 2026-2027 UIndy meal plans (19/12/8/4 Meal Plan) are defined in
[`lib/data/meal_plans_catalog.dart`](lib/data/meal_plans_catalog.dart). Update
that file for a new semester's pricing or to add/remove plans.

## Architecture

- `lib/models/` — `MealPlan` and `SwipeEntry` data classes.
- `lib/data/` — the hardcoded plan catalog.
- `lib/services/` — storage. `TrackerStore` is the storage contract;
  `DatabaseService` is the sqflite-backed implementation. A future backend
  (e.g. to sync multiple students) only needs a new `TrackerStore`.
- `lib/state/tracker_provider.dart` — all the business rules (weekly reset,
  daily/retail swipe caps, flex dollar balance) as a `ChangeNotifier`.
- `lib/screens/`, `lib/widgets/` — UI.

Storage is local-only for now (no accounts). `test/fakes/` has an in-memory
`TrackerStore` used by the test suite instead of real sqflite.

## Running

```
flutter pub get
flutter run
```

### Note for macOS: iCloud Drive + Xcode builds

If this project lives inside a folder synced by iCloud Drive (e.g. `~/Desktop`
or `~/Documents` with "Desktop & Documents Folders" sync enabled), `flutter
run`/`flutter build` for iOS or macOS can fail with:

```
Command CodeSign failed with a nonzero exit code
... resource fork, Finder information, or similar detritus not allowed
```

This is caused by iCloud's File Provider tagging build files with extended
attributes that `codesign` rejects — it isn't a problem with this project.
Fix it by either:

- Moving the project outside an iCloud-synced folder (e.g. `~/Developer`), or
- Excluding it from sync: System Settings → Apple ID → iCloud → iCloud Drive →
  turn off "Desktop & Documents Folders" (or exclude just this folder if your
  macOS version supports per-folder exclusion).

Android builds are unaffected.

## Testing

```
flutter test
flutter analyze
```
