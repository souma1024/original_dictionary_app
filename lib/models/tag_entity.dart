class TagEntity {
   final int? id;
   final String name;
   final String color;
   final DateTime createdAt; 
   final DateTime updatedAt;

    TagEntity({
      this.id,
      required this.name,
      required this.color,
      required this.createdAt,
      required this.updatedAt
    });

  factory TagEntity.fromMap(Map<String, dynamic> map ){

    DateTime safeParseDate(dynamic value) {
      if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return TagEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: (map['color'] as String?) ?? '#FFD7F0FF',
      createdAt: safeParseDate(map['created_at']),
      updatedAt: safeParseDate(map['updated_at'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
}