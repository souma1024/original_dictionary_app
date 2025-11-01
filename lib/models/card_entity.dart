class CardEntity {
  final int? id;
  final String name;
  final String nameHira;
  final String intro;
  final String introHira;
  final bool isFave;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 通常のコンストラクタ
  CardEntity({
    this.id,
    required this.name,
    required this.nameHira,
    required this.intro,
    required this.introHira,
    required this.isFave,
    required this.createdAt,
    required this.updatedAt,
  });

  CardEntity copyWith({
    int? id,
    String? name,
    String? nameHira,
    String? intro,
    String? introHira,
    bool? isFave,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CardEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHira: nameHira ?? this.nameHira,
      intro: intro ?? this.intro,
      introHira: introHira ?? this.introHira,
      isFave: isFave ?? this.isFave,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Map → CardEntity（DB読み込み時など）
  factory CardEntity.fromMap(Map<String, dynamic> map) {
    return CardEntity(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      nameHira: map['name_hira']?.toString() ?? '',
      intro: map['intro']?.toString() ?? '',
      introHira: map['intro_hira']?.toString() ?? '',
      isFave: (map['is_fave'] ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // CardEntity → Map（DB保存時など）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_hira': nameHira,
      'intro': intro,
      'intro_hira': introHira,
      'is_fave': isFave ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
