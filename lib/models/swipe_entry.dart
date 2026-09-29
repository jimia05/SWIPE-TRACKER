enum EntryType {
  mealSwipe,
  flexDollar;

  String get storageValue => name;

  static EntryType fromStorage(String value) =>
      EntryType.values.firstWhere((e) => e.storageValue == value);
}

enum SwipeLocation {
  diningHall('Dining Hall'),
  retail('Retail (PERK / Streets Grill)');

  const SwipeLocation(this.label);
  final String label;

  String get storageValue => name;

  static SwipeLocation fromStorage(String value) =>
      SwipeLocation.values.firstWhere((e) => e.storageValue == value);
}

/// A single logged event against a student's meal plan: either a meal swipe
/// (at a dining hall or a retail spot) or a flex dollar purchase.
class SwipeEntry {
  SwipeEntry({
    this.id,
    required this.type,
    required this.timestamp,
    this.location,
    this.amount,
    this.note,
  });

  final int? id;
  final EntryType type;
  final DateTime timestamp;

  /// Set for [EntryType.mealSwipe] entries; null for flex dollar entries.
  final SwipeLocation? location;

  /// Dollar amount spent; set for [EntryType.flexDollar] entries only.
  final double? amount;

  final String? note;

  SwipeEntry copyWith({int? id}) => SwipeEntry(
    id: id ?? this.id,
    type: type,
    timestamp: timestamp,
    location: location,
    amount: amount,
    note: note,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type.storageValue,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'location': location?.storageValue,
    'amount': amount,
    'note': note,
  };

  factory SwipeEntry.fromMap(Map<String, Object?> map) => SwipeEntry(
    id: map['id'] as int?,
    type: EntryType.fromStorage(map['type'] as String),
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    location: map['location'] == null
        ? null
        : SwipeLocation.fromStorage(map['location'] as String),
    amount: (map['amount'] as num?)?.toDouble(),
    note: map['note'] as String?,
  );
}
