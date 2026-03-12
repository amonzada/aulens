/// A school subject (e.g., "Mathematics").
class Subject {
  final int? id;
  final String name;

  const Subject({this.id, required this.name});

  Subject copyWith({int? id, String? name}) =>
      Subject(id: id ?? this.id, name: name ?? this.name);

  /// Used for DB inserts – `id` is excluded as it is AUTOINCREMENT.
  Map<String, dynamic> toMap() => {'name': name};

  factory Subject.fromMap(Map<String, dynamic> m) =>
      Subject(id: m['id'] as int, name: m['name'] as String);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Subject && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Subject(id: $id, name: $name)';
}
