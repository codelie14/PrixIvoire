import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class SearchHistory extends HiveObject {
  @HiveField(0)
  final String query;

  @HiveField(1)
  final DateTime searchedAt;

  SearchHistory({
    required this.query,
    DateTime? searchedAt,
  }) : searchedAt = searchedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      query: map['query'] ?? '',
      searchedAt: map['searchedAt'] != null
          ? DateTime.parse(map['searchedAt'])
          : DateTime.now(),
    );
  }
}
