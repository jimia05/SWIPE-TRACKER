import 'package:swipe_tracker/models/swipe_entry.dart';
import 'package:swipe_tracker/services/tracker_store.dart';

/// Plain in-memory [TrackerStore] used in widget/unit tests instead of the
/// real sqflite-backed [DatabaseService], which relies on native FFI that
/// doesn't run under the widget-test engine.
class InMemoryTrackerStore implements TrackerStore {
  final Map<String, String> _settings = {};
  final List<SwipeEntry> _entries = [];
  int _nextId = 1;

  @override
  Future<String?> getSetting(String key) async => _settings[key];

  @override
  Future<void> setSetting(String key, String value) async {
    _settings[key] = value;
  }

  @override
  Future<SwipeEntry> insertEntry(SwipeEntry entry) async {
    final stored = entry.copyWith(id: _nextId++);
    _entries.add(stored);
    return stored;
  }

  @override
  Future<void> deleteEntry(int id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<SwipeEntry>> allEntries() async {
    final sorted = [..._entries]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }
}
