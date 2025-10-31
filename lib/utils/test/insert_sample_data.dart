import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/repository/card_tag_repository.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/models/tag_entity.dart';

/// カード・タグ・中間テーブルをまとめて挿入する
Future<void> insertSampleData() async {
  final cardRepo = CardRepository.instance;
  final tagRepo = TagRepository.instance;
  final cardTagRepo = CardTagRepository.instance;

  // --- カード ---
  final List<CardEntity> cards = [
    CardEntity(
      name: "富士山麓オウムなく",
      nameHira: "ふじさんろくおうむなく",
      intro: "富士山のふもとではオウムの鳴き声も聞こえない。",
      introHira: "ふじさんのふもとではおうむのなきごえもきこえない。",
      isFave: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CardEntity(
      name: "桜花爛漫",
      nameHira: "おうからんまん",
      intro: "満開の桜が美しく咲き誇るさま。",
      introHira: "まんかいのさくらがうつくしくさいきほこるさま。",
      isFave: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CardEntity(
      name: "一期一会",
      nameHira: "いちごいちえ",
      intro: "一生に一度の出会いを大切にするという意味。",
      introHira: "いっしょうにいちどのであいをたいせつにするといういみ。",
      isFave: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CardEntity(
      name: "風林火山",
      nameHira: "ふうりんかざん",
      intro: "武田信玄の軍旗に由来する四字熟語。",
      introHira: "たけだしんげんのぐんきにゆらいするよじじゅくご。",
      isFave: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CardEntity(
      name: "花鳥風月",
      nameHira: "かちょうふうげつ",
      intro: "自然の美しさや季節の風情を楽しむこと。",
      introHira: "しぜんのうつくしさやきせつのふぜいをたのしむこと。",
      isFave: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final insertedIds = <int>[];
  for (final c in cards) {
    final id = await cardRepo.insertCard(c);
    insertedIds.add(id);
  }

  // --- タグ ---
  final List<TagEntity> tags = [
    TagEntity(
      name: '自然',
      color: '#81C784', // 緑系
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TagEntity(
      name: '名言',
      color: '#64B5F6', // 青系
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TagEntity(
      name: '季節',
      color: '#FFD54F', // 黄系
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TagEntity(
      name: '歴史',
      color: '#BA68C8', // 紫系
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TagEntity(
      name: '人生訓',
      color: '#E57373', // 赤系
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final tagIds = <int>[];
  for (final t in tags) {
    final id = await tagRepo.insertTag(t);
    tagIds.add(id);
  }

  // --- 紐付け（カード ↔ タグ） ---
  // 例としてランダムではなくテーマ的に関連づけ
  await cardTagRepo.attachTag(insertedIds[0], tagIds[0]); // 富士山麓→自然
  await cardTagRepo.attachTag(insertedIds[1], tagIds[2]); // 桜花爛漫→季節
  await cardTagRepo.attachTag(insertedIds[2], tagIds[4]); // 一期一会→人生訓
  await cardTagRepo.attachTag(insertedIds[3], tagIds[3]); // 風林火山→歴史
  await cardTagRepo.attachTag(insertedIds[4], tagIds[0]); // 花鳥風月→自然
  await cardTagRepo.attachTag(insertedIds[4], tagIds[2]); // 花鳥風月→季節

  print('✅ サンプルデータを挿入しました');
}