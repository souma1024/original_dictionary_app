import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';

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

    m[colCreatedAt] = TimeHelper.toIso(m[colCreatedAt], required: true);
    if (m[colUpdatedAt] != null) {
      m[colUpdatedAt] = (m[colUpdatedAt] is int)
        ? DateTime.fromMillisecondsSinceEpoch(m[colUpdatedAt] as int).toIso8601String()
        : m[colUpdatedAt];
    }

    return TagEntity.fromMap(m);
  }

  Future<List<TagEntity>> searchSimilarTags(String query, {int limit = 8}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final db = await AppDatabase.instance.database;

    // LIKE検索用にエスケープ
    String esc(String s) => s
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');

    final likeAny = '%${esc(q)}%';
    final likePrefix = '${esc(q)}%';

    final rows = await db.rawQuery(
      '''
      SELECT id, name, created_at, updated_at
      FROM tags
      WHERE name LIKE ? ESCAPE '\\'
      ORDER BY
        (name LIKE ? ESCAPE '\\') DESC,  -- 先頭一致を最優先
        LENGTH(name) ASC,                -- 短い順
        name ASC
      LIMIT ?
      ''',
      [likeAny, likePrefix, limit],
    );
    return rows.map((r) => fromRow(r)).toList();
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
