class CardPreview {
  final int id;
  final String name;
  final String intro;
  final DateTime updatedAt;

  CardPreview({
    required this.id,
    required this.name,
    required this.intro,
    required this.updatedAt,
  });

  factory CardPreview.fromMap(Map<String, dynamic> m) {
    return CardPreview(
      id: m['id'] as int,
      name: m['name'] as String,
      intro: m['intro'] as String,
      updatedAt: DateTime.parse(m['updated_at'] as String),
    );
  }
}