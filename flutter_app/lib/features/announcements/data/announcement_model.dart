// ── Model ─────────────────────────────────────────────────────────────────────
class Announcement {
  final String id;
  final String title;
  final String body;
  final String category;
  final String author;
  final DateTime createdAt;
  final bool isImportant;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.author,
    required this.createdAt,
    required this.isImportant,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] ?? json['_id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        category: json['category'] ?? 'general',
        author: json['author'] ?? 'Admin',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        isImportant: json['is_important'] == true || json['is_important'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'author': author,
        'created_at': createdAt.toIso8601String(),
        'is_important': isImportant ? 1 : 0,
      };

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement.fromJson(map);
}
