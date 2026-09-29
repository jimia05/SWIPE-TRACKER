import '../models/swipe_entry.dart';

/// Storage contract for the tracker: swipe/flex-dollar history plus a
/// small key-value settings store (selected plan, semester start date).
///
/// [DatabaseService] is the real, sqflite-backed implementation. Tests use
/// an in-memory fake instead. A future backend (e.g. for syncing multiple
/// students) only needs a new implementation of this interface — nothing
/// in [TrackerProvider] or the UI depends on how storage actually works.
abstract class TrackerStore {
  Future<String?> getSetting(String key);
  Future<void> setSetting(String key, String value);

  Future<SwipeEntry> insertEntry(SwipeEntry entry);
  Future<void> deleteEntry(int id);
  Future<List<SwipeEntry>> allEntries();
}
