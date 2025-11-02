import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/dto/card_preview.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/utils/security/input_sanitizer.dart';
import 'package:original_dict_app/data/mapper/card_mapper.dart';
import 'package:jp_transliterate/jp_transliterate.dart';
import 'package:sqflite/sqflite.dart';

class CardRepository {
  CardRepository._();
  static final CardRepository instance = CardRepository._();

  static const String fts4Table = 'cards_fts';
  static const String table = 'cards';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colNameHira = 'name_hira';
  static const String colIntro = 'intro';
  static const String colIntroHira = 'intro_hira';
  static const String colIsFave = 'is_fave';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colCardId = 'card_id';
  static const int displaylimitCards = 7;

  /// 検索 or 全件をまとめて取得（UI向け統一口）
  Future<List<CardHit>> listForDisplay(
      String query, {int limit = displaylimitCards, int offset = 0}) {
    final q = query.trim();
    return q.isEmpty
        ? getCardsAsHits(limit: limit, offset: offset)
        : searchCards(q, limit: limit, offset: offset);
  }

  Future<List<CardHit>> searchCards(
      String rawQuery, {
        int limit = displaylimitCards,
        int offset = 0,
      }) async {
    final db = await AppDatabase.instance.database;
    final qNorm = rawQuery;
    final contains = isVeryShort(qNorm);

    if (contains) {
      final nameExpr = colExpr(colName, toks(qNorm));
      final nameHiraExpr = colExpr(colNameHira, toks(qNorm));
      final introExpr = colExpr(colIntro, toks(qNorm));
      final introHiraExpr = colExpr(colIntroHira, toks(qNorm));

      final matchExpr = [nameExpr, nameHiraExpr, introExpr, introHiraExpr]
          .where((e) => e.isNotEmpty)
          .join(' OR ');

      final sql = '''
        SELECT 
          m.$colId,
          m.$colName,
          m.$colIntro,
          m.$colIsFave,
          m.$colUpdatedAt
        FROM $fts4Table
        JOIN $table AS m ON m.$colId = $fts4Table.$colCardId
        WHERE $fts4Table MATCH ?
        ORDER BY m.$colUpdatedAt DESC, m.$colId DESC
        LIMIT ? OFFSET ?
      ''';
      final rows = await db.rawQuery(sql, [matchExpr, limit, offset]);
      return rows
          .map((r) => CardHit(card: CardPreview.fromMap(r), snippet: null))
          .toList();
    } else {
      final normTokens = toks(qNorm).map((t) => '%${escapeLike(t)}%').toList();

      final sql = '''
          SELECT 
            m.$colId,
            m.$colName, 
            m.$colIntro,
            m.$colIsFave,
            m.$colUpdatedAt
          FROM $table AS m
          WHERE
            (${List.filled(normTokens.length, 'm.name LIKE ? ESCAPE \'\\\'').join(' AND ')})
            OR
            (${List.filled(normTokens.length, 'm.name_hira LIKE ? ESCAPE \'\\\'').join(' AND ')})
            OR
            (${List.filled(normTokens.length, 'm.intro LIKE ? ESCAPE \'\\\'').join(' AND ')})
            OR
            (${List.filled(normTokens.length, 'm.intro_hira LIKE ? ESCAPE \'\\\'').join(' AND ')})
          ORDER BY m.$colUpdatedAt DESC, m.$colId DESC
          LIMIT ? OFFSET ?
        ''';
      final args = [...normTokens, ...normTokens, ...normTokens, ...normTokens, limit, offset];
      final rows = await db.rawQuery(sql, args);
      return rows
          .map((r) => CardHit(card: CardPreview.fromMap(r), snippet: null))
          .toList();
    }
  }

  /// ✅ 並び替え対応版
  Future<List<CardHit>> getCardsAsHits({
    int page = 0,
    int limit = displaylimitCards,
    int offset = 0,
    String orderBy = 'updated_at DESC, id DESC', // ← 並び順を引数で指定可能に
  }) async {
    final db = await AppDatabase.instance.database;
    final actualOffset = offset > 0 ? offset : page * limit;

    final rows = await db.query(
      table,
      columns: [colId, colName, colIntro, colIsFave, colUpdatedAt],
      orderBy: orderBy,
      limit: limit,
      offset: actualOffset,
    );

    return rows
        .map((m) => CardHit(card: CardPreview.fromMap(m), snippet: null))
        .toList();
  }

  Future<List<CardEntity>> getCards({
    int limit = 15,
    int offset = 0,
  }) async {
    final db = await AppDatabase.instance.database;
    final sql = '''
      SELECT
        m.$colId,
        m.$colName,
        m.$colNameHira,
        m.$colIntro,
        m.$colIntroHira,
        m.$colIsFave,
        m.$colCreatedAt,
        m.$colUpdatedAt
      FROM $table AS m
      ORDER BY m.$colUpdatedAt DESC, m.$colId DESC
      LIMIT ? OFFSET ?
    ''';
    final rows = await db.rawQuery(sql, [limit, offset]);
    return rows.map((r) => CardMapper.toEntity(r)).toList();
  }

  Future<int> getCardCount() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<CardEntity?> getCardById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CardMapper.toEntity(rows.first);
  }

  Future<int> insertCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txn) async {
      final results = await Future.wait([
        JpTransliterate.transliterate(kanji: card.name),
        JpTransliterate.transliterate(kanji: card.intro),
      ]);
      final nameHira = results[0].hiragana;
      final introHira = results[1].hiragana;

      final map = card.toMap();
      map[colNameHira] = nameHira;
      map[colIntroHira] = introHira;
      if (map[colId] != null) map[colId] = null;

      final rowId = await txn.insert(table, map);

      await txn.insert(fts4Table, {
        colName: card.name,
        colNameHira: nameHira,
        colIntro: card.intro,
        colIntroHira: introHira,
        colCardId: rowId,
      });

      return rowId;
    });
  }

  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txn) async {
      await txn.delete(fts4Table, where: '$colCardId = ?', whereArgs: [id]);
      return await txn.delete(table, where: '$colId = ?', whereArgs: [id]);
    });
  }

  Future<int> deleteCards(List<int> ids) async {
    if (ids.isEmpty) return 0;
    const maxVars = 900;
    final db = await AppDatabase.instance.database;
    int totalMainDeleted = 0;

    await db.transaction((txn) async {
      for (var i = 0; i < ids.length; i += maxVars) {
        final chunk = ids.sublist(i, (i + maxVars).clamp(0, ids.length));
        final placeholders = List.filled(chunk.length, '?').join(',');
        await txn.delete(
          fts4Table,
          where: '$colCardId IN ($placeholders)',
          whereArgs: chunk,
        );
        final mainDeleted = await txn.delete(
          table,
          where: '$colId IN ($placeholders)',
          whereArgs: chunk,
        );
        totalMainDeleted += mainDeleted;
      }
    });
    return totalMainDeleted;
  }

  Future<int> updateCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    final map = card.toMap();
    final nameData = await JpTransliterate.transliterate(kanji: card.name);
    final introData = await JpTransliterate.transliterate(kanji: card.intro);

    map[colUpdatedAt] = DateTime.now().toIso8601String();
    map[colNameHira] = nameData.hiragana;
    map[colIntroHira] = introData.hiragana;

    return await db.transaction((txn) async {
      final affected = await txn.update(
        table,
        map,
        where: '$colId = ?',
        whereArgs: [card.id],
      );

      await txn.delete(fts4Table, where: '$colCardId = ?', whereArgs: [card.id]);
      await txn.insert(fts4Table, {
        colName: card.name,
        colNameHira: nameData.hiragana,
        colIntro: card.intro,
        colIntroHira: introData.hiragana,
        colCardId: card.id,
      });
      return affected;
    });
  }
}
