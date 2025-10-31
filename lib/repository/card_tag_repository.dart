import 'package:original_dict_app/data/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:original_dict_app/models/tag_entity.dart';

class CardTagRepository {
  CardTagRepository._();
  static final CardTagRepository instance = CardTagRepository._();

  static const table = 'card_tags';
  static const colId = 'id';
  static const colCardId = 'card_id';
  static const colTagId = 'tag_id';
  static const colCreatedAt = 'created_at';

  /// カードにタグを追加（重複は無視）
  Future<int> attachTag(int cardId, int tagId) async {
    final db = await AppDatabase.instance.database;
    return db.insert(
      table,
      {
        colCardId: cardId,
        colTagId: tagId,
        colCreatedAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// カードからタグを解除
  Future<int> detachTag(int cardId, int tagId) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      table,
      where: '$colCardId = ? AND $colTagId = ?',
      whereArgs: [cardId, tagId],
    );
  }

  /// カードに付与されているタグID一覧を取得
  Future<List<int>> getTagIdsByCard(int cardId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      columns: [colTagId],
      where: '$colCardId = ?',
      whereArgs: [cardId],
    );
    return rows.map((r) => r[colTagId] as int).toList();
  }

  /// タグに紐づくカードID一覧を取得
  Future<List<int>> getCardIdsByTag(int tagId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      columns: [colCardId],
      where: '$colTagId = ?',
      whereArgs: [tagId],
    );
    return rows.map((r) => r[colCardId] as int).toList();
  }

  /// トグル（ついていれば削除、なければ追加）
  Future<void> toggleTag(int cardId, int tagId) async {
    final db = await AppDatabase.instance.database;
    final exists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM $table WHERE $colCardId = ? AND $colTagId = ?',
      [cardId, tagId],
    ));
    if (exists != null && exists > 0) {
      await detachTag(cardId, tagId);
    } else {
      await attachTag(cardId, tagId);
    }
  }

  Future<List<TagEntity>> getTagsByCard(int cardId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT t.id, t.name, t.color, t.updated_at
      FROM $table ct
      INNER JOIN tags t ON t.id = ct.$colTagId
      WHERE ct.$colCardId = ?
      ORDER BY t.name COLLATE NOCASE
    ''', [cardId]);

    return rows.map((r) => TagEntity.fromMap(r)).toList();
  }

  Future<Map<int, List<TagEntity>>> getTagsByCardIds(List<int> cardIds) async {
    if (cardIds.isEmpty) return {};

    final db = await AppDatabase.instance.database;

    // IN句を安全に作成
    final placeholders = List.filled(cardIds.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT ct.$colCardId as card_id, t.id, t.name, t.color, t.updated_at
      FROM $table ct
      INNER JOIN tags t ON t.id = ct.$colTagId
      WHERE ct.$colCardId IN ($placeholders)
      ORDER BY ct.$colCardId, t.name COLLATE NOCASE
    ''', cardIds);

    final map = <int, List<TagEntity>>{};
    for (final r in rows) {
      final cardId = r['card_id'] as int;
      final tag = TagEntity.fromMap(r);
      (map[cardId] ??= []).add(tag);
    }
    return map;
  }

}