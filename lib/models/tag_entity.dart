class TagEntity {
   final int? id;
   final String name;
   final DateTime createdAt; 
   final DateTime updatedAt;

    TagEntity({
      this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt
    });

  factory TagEntity.fromMap(Map<String, dynamic> map ){
    return CardEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
}