import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/dto/card_preview.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/dto/card_hit.dart'  ;
import 'package:original_dict_app/utils/security/input_sanitizer.dart';
import 'package:original_dict_app/data/mapper/card_mapper.dart';
import 'package:jp_transliterate/jp_transliterate.dart';

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
    return q.isEmpty ? getCardsAsHits(limit: limit, offset: offset) : searchCards(q, limit: limit, offset: offset);
  }

  Future<List<CardHit>> searchCards(
    String rawQuery, {
    int limit = displaylimitCards,
    int offset = 0, // offsetは、それまでの行をスキップする（offset=10なら11行目から読み込まれる）
  }) async {
    final db = await AppDatabase.instance.database;
    final qNorm = rawQuery;

    final contains = isVeryShort(qNorm);

    if (contains) {

      // 列ごとの式を作る（各列内は AND）
      final nameExpr      = colExpr(colName, toks(qNorm));
      final nameHiraExpr  = colExpr(colNameHira, toks(qNorm));
      final introExpr     = colExpr(colIntro, toks(qNorm));
      final introHiraExpr = colExpr(colIntroHira, toks(qNorm));

      // 列間は OR
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
        ORDER BY datetime(m.$colUpdatedAt) DESC, m.$colId DESC
        LIMIT ? OFFSET ?
      ''';
      final rows = await db.rawQuery(sql, [matchExpr, limit, offset]);
      return rows.map((r) => CardHit(card: CardPreview.fromMap(r), snippet: null)).toList();
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
          ORDER BY datetime(m.$colUpdatedAt) DESC, m.$colId DESC
          LIMIT ? OFFSET ?
        ''';
        final args = [...normTokens, ...normTokens, ...normTokens, ...normTokens, limit, offset];
        final rows = await db.rawQuery(sql, args);
        // 自前ハイライト（簡易）
        return rows.map((r) => CardHit(card: CardPreview.fromMap(r), snippet: null)).toList();
    }
  }

  // カードを生成するディスプレイ用
  Future<List<CardHit>> getCardsAsHits({
    int limit = displaylimitCards,
    int offset = 0,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table, // $table
      columns: [colId, colName, colIntro, colIsFave, colUpdatedAt], // 必要列だけ
      orderBy: 'datetime($colUpdatedAt) DESC, $colId DESC',
      limit: limit,
      offset: offset,
    );
    return rows
        .map((m) => CardHit(
              card: CardPreview.fromMap(m), // 直接Map→CardPreview
              snippet: null,
            ))
        .toList();
  }

  // フルエンティティ取得（詳細画面などで使用）
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
      ORDER BY datetime(m.$colUpdatedAt) DESC, m.$colId DESC
      LIMIT ? OFFSET ?
    ''';
    final rows = await db.rawQuery(sql, [limit, offset]);
    return rows.map((r) => CardMapper.toEntity(r)).toList(); 
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
    // ← List なので first を渡す
    return CardMapper.toEntity(rows.first);
  }

  /// 戻り値: 追加されたレコードの rowId
  Future<int> insertCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txn) async {
       // ひらがな化（並列）
      final results = await Future.wait([
        JpTransliterate.transliterate(kanji: card.name),
        JpTransliterate.transliterate(kanji: card.intro),
      ]);
      final nameHira  = results[0].hiragana;
      final introHira = results[1].hiragana;

      // メインテーブル用の map を補正（name_hira を必ず入れる）
      final map = card.toMap();
      map[colNameHira] = nameHira;
      map[colIntroHira] = introHira;
      // id をDB採番に任せたい場合は、念のため null へ
      if (map[colId] != null) map[colId] = null;

      // メイン挿入
      final rowId = await txn.insert(table, map);

      // FTS 側も挿入
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

  /// 戻り値: 影響行数（0 or 1）
  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txn) async {
      await txn.delete(fts4Table, where: '$colCardId = ?', whereArgs: [id]);
      final count = await txn.delete(table, where: '$colId = ?', whereArgs: [id]);
      return count;
    });
  }

  // 複数削除
  Future<int> deleteCards(List<int> ids) async {
    if (ids.isEmpty) return 0;

    // SQLite のバインド数上限（既定 999）を考慮して分割
    const maxVars = 900; // 余裕を持たせる
    final db = await AppDatabase.instance.database;

    int totalMainDeleted = 0;

    await db.transaction((txn) async {
      for (var i = 0; i < ids.length; i += maxVars) {
        final chunk = ids.sublist(i, (i + maxVars).clamp(0, ids.length));
        final placeholders = List.filled(chunk.length, '?').join(',');

        // 1) まず関連するFTS行を削除（FKやトリガがない前提）
        await txn.delete(
          fts4Table,
          where: '$colCardId IN ($placeholders)',
          whereArgs: chunk,
        );

        // 2) 本体テーブルを削除
        final mainDeleted = await txn.delete(
          table,
          where: '$colId IN ($placeholders)',
          whereArgs: chunk,
        );

        totalMainDeleted += mainDeleted;
      }
    });
    return totalMainDeleted; // ← 本体テーブルで削除できた件数を返す
  }

  /// 戻り値: 影響行数（0 or 1）
  Future<int> updateCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    final map = card.toMap();
    final nameData  = await JpTransliterate.transliterate(kanji: card.name);
    final introData = await JpTransliterate.transliterate(kanji: card.intro);

    map[colUpdatedAt] = DateTime.now().toIso8601String(); // ← 自動更新
    map[colNameHira]  = nameData.hiragana;
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