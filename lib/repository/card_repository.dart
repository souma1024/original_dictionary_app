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

  String _toLikePattern(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    return '%${s.replaceAll('\\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
  }

  Future<List<CardEntity>> searchByNameContains(
    String query, {
    int limit = 50,
    int offset = 0,
    bool caseInsensitive = true,
  }) async {
    final q = _toLikePattern(query);
    if (q.isEmpty) return const [];

    final db = await AppDatabase.instance.database;

    // 大小無視は LOWER(name) LIKE LOWER(?) を使うのが移植性高い
    final where = caseInsensitive
        ? 'LOWER($colName) LIKE LOWER(?) ESCAPE "\\"'
        : '$colName LIKE ? ESCAPE "\\"';

    final rows = await db.query(
      table,
      where: where,
      whereArgs: [q],
      limit: limit,
      offset: offset,
      orderBy: '$colName ASC, $colId ASC',
    );

    return rows.map(fromRow).toList();
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
    return db.insert(
      table,
      card.toMap(),
    );
  }

  /// 戻り値: 影響行数（0 or 1）
  Future<int> deleteCard(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  /// 戻り値: 影響行数（0 or 1）
  Future<int> updateCard(CardEntity card) async {
    final db = await AppDatabase.instance.database;
    final map = card.toMap();
    map[colUpdatedAt] = DateTime.now().toIso8601String(); // ← 自動更新

    return db.update(
      table,
      map,
      where: '$colId = ?',
      whereArgs: [card.id],
    );
  }
}