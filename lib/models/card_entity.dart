class CardEntity {
  final int? id;
  final String name;
  final String intro;
  final bool isFave;
  final DateTime createdAt;
  final DateTime updatedAt; //作成時は値が入らないので、null許容

  // デフォルトコンストラクタ
  CardEntity({
    this.id,
    required this.name,
    required this.intro,
    required this.isFave,
    required this.createdAt,
    required this.updatedAt
  });

  // 名前付きコンストラクタ
  factory CardEntity.fromMap(Map<String, dynamic> map) {
    return CardEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      intro: map['intro'] as String,
      isFave: (map['is_fave'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'intro': intro,
      'is_fave': isFave ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

}