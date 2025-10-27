import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';
import '../models/card_entity.dart';

class CardRepository {
  CardRepository._();
  static final CardRepository instance = CardRepository._();

  static const String table = 'cards';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colIntro = 'intro';
  static const String colIsFave = 'is_fave';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // 「DBの生データ → 安全な Dart のモデル」変換
  CardEntity fromRow(Map<String, Object?> row) {
    final m = Map<String, dynamic>.from(row);

    // is_fave を 0/1 に正規化
    final fav = m[colIsFave];
    if (fav is bool) {
      m[colIsFave] = fav ? 1 : 0;
    } else if (fav is String) {
      m[colIsFave] = (fav == '1' || fav.toLowerCase() == 'true') ? 1 : 0;
    }

    // created_at / updated_at を ISO8601 形式に統一
    String toIso(dynamic v, {bool required = false}) {
      if (v == null) {
        return DateTime.now().toIso8601String();
      }
      if (v is int) {
        return DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
      }
      if (v is String) return v;
      return DateTime.now().toIso8601String();
    }

    m[colCreatedAt] = toIso(m[colCreatedAt]);
    m[colUpdatedAt] = toIso(m[colUpdatedAt]);

    return CardEntity.fromMap(m);
  }

  // 全取得
  Future<List<CardEntity>> getCards() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(table);
    return rows.map((r) => fromRow(r)).toList();
  }

  // ✅ 追加：ページング対応版カード取得
  Future<List<CardEntity>> getCardsByPage({
    required int page,
    required int limit,
  }) async {
    final db = await AppDatabase.instance.database;
    final offset = (page - 1) * limit;

    final rows = await db.query(
      table,
      orderBy: '$colId ASC', // ← 並び順を固定！これが重要
      limit: limit,
      offset: offset,
    );

    return rows.map((row) => fromRow(row)).toList();
  }


  // ✅ 追加：総件数を取得（最大ページ数の計算に使う）
  Future<int> getCardCount() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ID検索
  Future<CardEntity?> getCardById(int id) async {
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

  // 追加
  Future<int> insertCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    return db.insert(table, card.toMap());
  }

  // 削除
  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // 更新（更新日時を自動更新）
  Future<int> updateCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    final map = card.toMap();
    map[colUpdatedAt] = DateTime.now().toIso8601String();
    return db.update(
      table,
      map,
      where: '$colId = ?',
      whereArgs: [card.id],
    );
  }
}
