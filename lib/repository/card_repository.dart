import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';
import '../models/card.dart';

class CardRepository {
  CardRepository._();
  static final CardRepository instance = CardRepository._();

  Future<int> addCard({
    required String name,
    required String intro,
  }) async {
    final db = await AppDatabase.instance.database;

    final card = Card(
      name: name,
      intro: intro,
      isFave: false,
      createdAt: DateTime.now(),
    );

    return await db.insert('cards', card.toMap());
  }


  // Future<void> updateCard({
  //   required String name,
  //   required String intro,
  // }) async {
  //   final db = await AppDatabase.instance.database;

  //   final card = Card(
  //     name: name,
  //     intro: intro,
  //     isFave: false,
  //     updatedAt: DateTime.now(),
  //   );

  //   return await db.update('cards', card.toMap());
  // }



}