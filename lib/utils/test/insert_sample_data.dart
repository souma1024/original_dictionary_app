import 'package:original_dict_app/data/app_database.dart';

Future<void> insertSampleData() async {
  final db = await AppDatabase.instance.database;

  // 既存データを消したい場合（必要に応じて）
  // await db.delete('card_tags');
  // await db.delete('tags');
  await db.delete('cards');

  // タグを5個くらい作成
  // final tagIds = <int>[];
  // for (int i = 1; i <= 5; i++) {
  //   final id = await db.insert('tags', {
  //     'name': 'タグ$i',
  //   });
  //   tagIds.add(id);
  // }

  // カードを30件作成
  for (int i = 1; i <= 30; i++) {
    await db.insert('cards', {
      'name': '単語$i',
      'intro': 'これはサンプル $i の説明です。少しだけ長い文章の時はどうなるか',
      'is_fave': i % 5 == 0 ? 1 : 0, // 5件に1件だけお気に入り
    });
  }
    // ランダムで0〜2個タグをつける
  //   final rnd = Random();
  //   final tagCount = rnd.nextInt(3); // 0,1,2
  //   final used = <int>{};

  //   for (int t = 0; t < tagCount; t++) {
  //     final tagId = tagIds[rnd.nextInt(tagIds.length)];
  //     if (used.contains(tagId)) continue;
  //     used.add(tagId);

  //     await db.insert('card_tags', {
  //       'card_id': cardId,
  //       'tag_id': tagId,
  //     });
  //   }
  // }

  print('✅ サンプルデータ（30件）を投入しました!');
}