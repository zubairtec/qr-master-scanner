import 'dart:convert';

class ScanResult {
  final String id;
  final String type;
  final String content;
  final DateTime timestamp;
  final bool isFavorite;

  ScanResult({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
  });

  // Convert to Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // Create from Map
  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'],
      type: map['type'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isFavorite: map['isFavorite'],
    );
  }

  // Convert to JSON string
  String toJson() => json.encode(toMap());

  // Create from JSON string
  factory ScanResult.fromJson(String source) =>
      ScanResult.fromMap(json.decode(source));

  // Copy with method
  ScanResult copyWith({
    String? id,
    String? type,
    String? content,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return ScanResult(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
