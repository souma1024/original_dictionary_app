import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/models/card_entity.dart';

class CardRepository {
  CardRepository._();
  static final CardRepository instance = CardRepository._();

  final db = AppDatabase.instance.database;

  /// カード一覧取得（検索 + 表示用）
  Future<List<CardHit>> listForDisplay(String query) async {
    final database = await db;
    final results = await database.query(
      'cards',
      where: 'name LIKE ? OR intro LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return results.map((e) => CardHit.fromMap(e)).toList();
  }

  /// カード件数取得
  Future<int> getCardCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as cnt FROM cards');
    return result.first['cnt'] as int;
  }

  /// カード一覧（limit + offset 指定）
  Future<List<CardHit>> getCardsAsHits({int limit = 20, int offset = 0}) async {
    final database = await db;
    final results = await database.query(
      'cards',
      orderBy: 'updated_at DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((e) => CardHit.fromMap(e)).toList();
  }

  /// ID指定でカードを取得
  Future<CardEntity?> getCardById(int id) async {
    final database = await db;
    final result =
    await database.query('cards', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return CardEntity.fromMap(result.first);
  }

  /// カードを追加
  Future<int> insertCard(CardEntity card) async {
    final database = await db;
    return await database.insert('cards', card.toMap());
  }

  /// カードを削除（複数対応）
  Future<int> deleteCards(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final database = await db;
    final idList = ids.join(',');
    return await database.rawDelete('DELETE FROM cards WHERE id IN ($idList)');
  }
}
