// ignore_for_file: public_member_api_docs

T fromFirestore<T>(Map<String, dynamic> data, T Function(Map<String, dynamic>) builder) => builder(data);
Map<String, dynamic> toFirestore(Map<String, Object?> map) {
  final m = Map<String, Object?>.from(map);
  m.removeWhere((_, v) => v == null);
  return m;
}
