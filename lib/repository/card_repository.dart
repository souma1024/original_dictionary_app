import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/dto/card_hit.dart'  ;
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
  static const String colIsFave = 'is_fave';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // 「DBの生データ → 安全な Dart のモデル」変換
  CardEntity fromRow(Map<String, Object?> row) {
    final m = Map<String, dynamic>.from(row);

    // is_fave を 0/1 に正規化（bool / "true"/"1" も許容）
    final fav = m[colIsFave];
    if (fav is bool) {
      m[colIsFave] = fav ? 1 : 0;
    } else if (fav is String) {
      m[colIsFave] = (fav == '1' || fav.toLowerCase() == 'true') ? 1 : 0;
    }

    // created_at / updated_at が int(UNIX ms) なら ISO8601 へ
    String toIso(dynamic v, {bool required = false}) {
      if (v == null) {
        if (required) {
          // created_at はモデル側で required なので最低限のフォールバック
          return DateTime.now().toIso8601String();
        }
        return DateTime.now().toIso8601String();
      }
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
      if (v is String) return v; // すでに ISO とみなす
      return DateTime.now().toIso8601String();
    }

    m[colCreatedAt] = toIso(m[colCreatedAt], required: true);
    if (m[colUpdatedAt] != null) {
      m[colUpdatedAt] = (m[colUpdatedAt] is int)
          ? DateTime.fromMillisecondsSinceEpoch(m[colUpdatedAt] as int).toIso8601String()
          : m[colUpdatedAt];
    }

    return CardEntity.fromMap(m);
  }

  String _normalize(String s) {
    return s.trim(); //文字列の前後から空白文字を取り除く
  }

  Future<List<CardHit>> searchCards(
    String rawQuery, {
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await AppDatabase.instance.database;

    final qNorm = _normalize(rawQuery);
    if (qNorm.isEmpty) {
      // 空クエリ → 新着順で返す（FTS 不使用）
      final rows = await db.query(
        table,
        orderBy: 'datetime($colUpdatedAt) DESC, $colId DESC',
        limit: limit,
        offset: offset,
      );
      return rows.map((r) => CardHit(card: CardEntity.fromMap(r))).toList();
    }

    // ひらがな化（クエリも両表記で検索）
    final hira = (await JpTransliterate.transliterate(kanji: qNorm)).hiragana;

    // トークン分割
    Iterable<String> toks(String s) =>
        s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);

    String toPrefix(String t) {
      // 引用符や空白は落とす（最小限のサニタイズ）
      final safe = t.replaceAll('"', '').replaceAll(RegExp(r'\s+'), '');
      return '$safe*';
    }

    // 列ごとの式を作る（各列内は AND）
    final nameExpr      = toks(qNorm).map((t) => 'name:${toPrefix(t)}').join(' ');
    final nameHiraExpr  = toks(hira).map((t) => 'name_hira:${toPrefix(t)}').join(' ');
    final introHiraExpr = toks(hira).map((t) => 'intro_hira:${toPrefix(t)}').join(' ');

    // 列間は OR
    final matchExpr = [nameExpr, nameHiraExpr, introHiraExpr]
        .where((e) => e.isNotEmpty)
        .join(' OR ');

    final sql = '''
      SELECT m.*,
            snippet(${CardRepository.fts4Table}, '<b>', '</b>', '…', 2) AS snip
      FROM ${CardRepository.fts4Table}
      JOIN ${CardRepository.table} AS m ON m.${CardRepository.colId} = ${CardRepository.fts4Table}.card_id
      WHERE ${CardRepository.fts4Table} MATCH ?
      ORDER BY datetime(m.${CardRepository.colUpdatedAt}) DESC, m.${CardRepository.colId} DESC
      LIMIT ? OFFSET ?
    ''';

    final rows = await db.rawQuery(sql, [matchExpr, limit, offset]);
    return rows.map((r) => CardHit(card: CardRepository.instance.fromRow(r), snippet: r['snip'] as String?)).toList();
  }

  Future<List<CardHit>> getCardsAsHits() async {
    final cards = await getCards();
    return cards.map((c) => CardHit(card: c, snippet: null)).toList();
  }

  /// 検索 or 全件をまとめて取得（UI向け統一口）
  Future<List<CardHit>> listForDisplay(String query) {
    final q = query.trim();
    return q.isEmpty ? getCardsAsHits() : searchCards(q);
  }

  Future<List<CardEntity>> getCards() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(table);
    // ← 必ず fromRow を通して型を整える
    return rows.map((r) => fromRow(r)).toList();
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
    return fromRow(rows.first);
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
      map['name_hira'] = nameHira;
      // id をDB採番に任せたい場合は、念のため null へ
      if (map['id'] != null) map['id'] = null;

      // メイン挿入
      final rowId = await txn.insert(table, map);

      // FTS 側も挿入
      await txn.insert(fts4Table, {
        'name': card.name,
        'name_hira': nameHira,
        'intro': card.intro,
        'intro_hira': introHira,
        'card_id': rowId,
      });

      return rowId;
    });
  }

  /// 戻り値: 影響行数（0 or 1）
  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.transaction((txn) async {
      await txn.delete(fts4Table, where: 'card_id = ?', whereArgs: [id]);
      final count = await txn.delete(table, where: 'id = ?', whereArgs: [id]);
      return count;
    });
  }

  /// 戻り値: 影響行数（0 or 1）
  Future<int> updateCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    final map = card.toMap();
    map[colUpdatedAt] = DateTime.now().toIso8601String(); // ← 自動更新

    return await db.transaction((txn) async {
      final affected = await txn.update(
        table,
        map,
        where: '$colId = ?',
        whereArgs: [card.id],
      );

      final nameData  = await JpTransliterate.transliterate(kanji: card.name);
      final introData = await JpTransliterate.transliterate(kanji: card.intro);

      await txn.delete(fts4Table, where: 'card_id = ?', whereArgs: [card.id]);
      await txn.insert(fts4Table, {
        'name': card.name,
        'name_hira': nameData.hiragana,
        'intro': card.intro,
        'intro_hira': introData.hiragana,
        'card_id': card.id,
      });
      return affected;
    });
  }
}