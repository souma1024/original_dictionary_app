import '../data/app_database.dart';
import '../models/tag_entity.dart';

class TagRepository {
  TagRepository._();
  static final TagRepository instance = TagRepository._();
  static const String table = 'tags';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  TagEntity fromRow(Map<String, Object?> row) {
    final m = Map<String, dynamic>.from(row);

    String toIso(dynamic v, {bool required = false}) {
      if (v == null) {
        if (required) {
          return DateTime.now().toIso8601String();
        }
        return DateTime.now().toIso8601String();
      }
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
      if (v is String) return v;
      return DateTime.now().toIso8601String();
    }

    m[colCreatedAt] = toIso(m[colCreatedAt], required: true);
    if (m[colUpdatedAt] != null) {
      m[colUpdatedAt] = (m[colUpdatedAt] is int)
        ? DateTime.fromMillisecondsSinceEpoch(m[colUpdatedAt] as int).toIso8601String()
        : m[colUpdatedAt];
    }

    return TagEntity.fromMap(m);
  }

  Future<List<TagEntity>> getTags() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(table);

    return rows.map((r) => fromRow(r)).toList();
  }

  Future<TagEntity?> getTagById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromRow(rows.first);
  }

  Future<int> insertTag(TagEntity tag) async {
    final db = await AppDatabase.instance.database;
    return db.insert(
      table,
      tag.toMap(),
    );
  }

  Future<int> deleteTag(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTag(TagEntity tag) async {
    final db = await AppDatabase.instance.database;
    final map = tag.toMap();
    map[colUpdatedAt] = DateTime.now().toIso8601String();

    return db.update(
      table,
      map,
      where: '$colId = ?',
      whereArgs: [tag.id],
    );
  }
}
