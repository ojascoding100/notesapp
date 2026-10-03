import 'dart:convert';

class Note {
  final String id;
  String title;
  String content;
  final DateTime dateAdded;
  String colorLabel;
  String category;
  String emoji;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateAdded,
    this.colorLabel = 'yellow',
    this.category = 'All',
    this.emoji = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateAdded': dateAdded.toIso8601String(),
      'colorLabel': colorLabel,
      'category': category,
      'emoji': emoji,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      colorLabel: map['colorLabel'] as String? ?? 'yellow',
      category: map['category'] as String? ?? 'All',
      emoji: map['emoji'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(jsonDecode(source) as Map<String, dynamic>);

  int get wordCount {
    final text = '$title $content'.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }
}
