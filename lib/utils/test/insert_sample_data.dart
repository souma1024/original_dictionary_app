import 'dart:math';
import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/repository/card_tag_repository.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/models/tag_entity.dart';

/// カード・タグ・中間テーブルをまとめて挿入する
Future<void> insertSampleData() async {
  final cardRepo = CardRepository.instance;
  final tagRepo = TagRepository.instance;

  // --- カード ---
  final List<CardEntity> cards = [
    CardEntity(name: "富士山麓オウムなく", nameHira: "ふじさんろくおうむなく", intro: "富士山のふもとではオウムの鳴き声も聞こえない。", introHira: "ふじさんのふもとではおうむのなきごえもきこえない。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "桜花爛漫", nameHira: "おうからんまん", intro: "満開の桜が美しく咲き誇るさま。", introHira: "まんかいのさくらがうつくしくさいきほこるさま。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期一会", nameHira: "いちごいちえ", intro: "一生に一度の出会いを大切にするという意味。", introHira: "いっしょうにいちどのであいをたいせつにするといういみ。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "風林火山", nameHira: "ふうりんかざん", intro: "武田信玄の軍旗に由来する四字熟語。", introHira: "たけだしんげんのぐんきにゆらいするよじじゅくご。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "花鳥風月", nameHira: "かちょうふうげつ", intro: "自然の美しさや季節の風情を楽しむこと。", introHira: "しぜんのうつくしさやきせつのふぜいをたのしむこと。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "温故知新", nameHira: "おんこちしん", intro: "古きをたずねて新しきを知る。", introHira: "ふるきをたずねてあたらしきをしる。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "晴耕雨読", nameHira: "せいこううどく", intro: "のどかに暮らす理想的な生活。", introHira: "のどかにくらすりそうてきなせいかつ。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "山紫水明", nameHira: "さんしすいめい", intro: "自然の美しい景色を表す言葉。", introHira: "しぜんのうつくしいけしきをあらわすことば。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "初心忘るべからず", nameHira: "しょしんわするべからず", intro: "初めの志を忘れてはならない。", introHira: "はじめのこころざしをわすれてはならない。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "雲外蒼天", nameHira: "うんがいそうてん", intro: "困難を乗り越えれば青空が広がる。", introHira: "こんなんをのりこえればあおぞらがひろがる。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "和顔愛語", nameHira: "わがんあいご", intro: "やさしい笑顔と温かい言葉で人に接すること。", introHira: "やさしいえがおとあたたかいことばでひとにせっすること。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期一笑", nameHira: "いちごいっしょう", intro: "出会う人すべてに笑顔を大切にすること。", introHira: "であうひとすべてにえがおをたいせつにすること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "春夏秋冬", nameHira: "しゅんかしゅうとう", intro: "四季の移り変わり。", introHira: "しきのうつりかわり。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "不撓不屈", nameHira: "ふとうふくつ", intro: "どんな困難にも屈しない強い心。", introHira: "どんなこんなんにもくっしないつよいこころ。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "臥薪嘗胆", nameHira: "がしんしょうたん", intro: "苦労して目的を達成しようとすること。", introHira: "くろうしてもくてきをたっせいしようとすること。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "七転八起", nameHira: "しちてんはっき", intro: "何度失敗しても立ち上がること。", introHira: "なんどしっぱいしてもたちあがること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一日一善", nameHira: "いちにちいちぜん", intro: "毎日一つ良いことをする。", introHira: "まいにちひとつよいことをする。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期千秋", nameHira: "いちごせんしゅう", intro: "再会を心から待ち望むこと。", introHira: "さいかいをこころからまちのぞむこと。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "切磋琢磨", nameHira: "せっさたくま", intro: "互いに励まし合って向上すること。", introHira: "たがいにはげましあってこうじょうすること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "自業自得", nameHira: "じごうじとく", intro: "自分の行いの結果は自分に返ってくる。", introHira: "じぶんのおこないのけっかはじぶんにかえってくる。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "有言実行", nameHira: "ゆうげんじっこう", intro: "言ったことは必ず実行する。", introHira: "いったことはかならずじっこうする。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "才色兼備", nameHira: "さいしょくけんび", intro: "知性と美しさを兼ね備えていること。", introHira: "ちせいとうつくしさをかねそなえていること。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "異口同音", nameHira: "いくどうおん", intro: "多くの人が同じ意見を言うこと。", introHira: "おおくのひとがおなじいけんをいうこと。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "明鏡止水", nameHira: "めいきょうしすい", intro: "澄み切った心の状態を表す。", introHira: "すみきったこころのじょうたいをあらわす。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期一筆", nameHira: "いちごいっぴつ", intro: "一度きりの筆致で心を込めて書くこと。", introHira: "いちどきりのひっちでこころをこめてかくこと。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "温厚篤実", nameHira: "おんこうとくじつ", intro: "穏やかで誠実な人柄。", introHira: "おだやかでせいじつなひとがら。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "心機一転", nameHira: "しんきいってん", intro: "気持ちを切り替えて新しいことに臨む。", introHira: "きもちをきりかえてあたらしいことにのぞむ。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期百笑", nameHira: "いちごひゃくしょう", intro: "笑顔あふれる一生を送りたいという願い。", introHira: "えがおあふれるいっしょうをおくりたいというねがい。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "誠心誠意", nameHira: "せいしんせいい", intro: "まごころをこめて行動すること。", introHira: "まごころをこめてこうどうすること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "悠々自適", nameHira: "ゆうゆうじてき", intro: "心穏やかに自由な生活を楽しむこと。", introHira: "こころおだやかにじゆうなしょうがいをたのしむこと。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期夢幻", nameHira: "いちごむげん", intro: "人生の儚さをあらわす。", introHira: "じんせいのはかなさをあらわす。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一石二鳥", nameHira: "いっせきにちょう", intro: "一つの行動で二つの利益を得ること。", introHira: "ひとつのこうどうでふたつのりえきをえること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "感慨無量", nameHira: "かんがいむりょう", intro: "深く感動すること。", introHira: "ふかくかんどうすること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "自他共栄", nameHira: "じたきょうえい", intro: "自分も他人も共に栄えるようにする。", introHira: "じぶんもたにんもともにさかえるようにする。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "日進月歩", nameHira: "にっしんげっぽ", intro: "絶えず進歩し続けること。", introHira: "たえずしんぽしつづけること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "温柔敦厚", nameHira: "おんじゅうとんこう", intro: "温かく誠実な人柄を意味する。", introHira: "あたたかくせいじつなひとがらをいみする。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "才気煥発", nameHira: "さいきかんぱつ", intro: "才能があふれているさま。", introHira: "さいのうがあふれているさま。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期青春", nameHira: "いちごせいしゅん", intro: "青春時代を大切に生きること。", introHira: "せいしゅんじだいをたいせつにいきること。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "百花繚乱", nameHira: "ひゃっかりょうらん", intro: "多くの才能が一度に花開くさま。", introHira: "おおくのさいのうがいちどにはなひらくさま。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "天真爛漫", nameHira: "てんしんらんまん", intro: "無邪気で明るい性格。", introHira: "むじゃきであかるいせいかく。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "勇往邁進", nameHira: "ゆうおうまいしん", intro: "勇気を持って目的に突き進む。", introHira: "ゆうきをもってもくてきにつきすすむ。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期真心", nameHira: "いちごまごころ", intro: "一度の出会いを心を込めて大切にする。", introHira: "いちどのであいをこころをこめてたいせつにする。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "泰然自若", nameHira: "たいぜんじじゃく", intro: "どんなことにも動じない心。", introHira: "どんなことにもどうじないこころ。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "栄枯盛衰", nameHira: "えいこせいすい", intro: "栄える時もあれば衰える時もある。", introHira: "さかえるときもあればおとろえるときもある。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "一期清風", nameHira: "いちごせいふう", intro: "爽やかで気持ちのよい人との出会い。", introHira: "さわやかできもちのよいひととのであい。", isFave: false, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CardEntity(name: "青天白日", nameHira: "せいてんはくじつ", intro: "疑いが晴れて潔白が明らかになること。", introHira: "うたがいがはれてけっぱくがあきらかになること。", isFave: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
  ];

  final insertedIds = <int>[];
  for (final c in cards) {
    final id = await cardRepo.insertCard(c);
    insertedIds.add(id);
  }

  // --- タグ ---
  final List<TagEntity> tags = [
    TagEntity(name: '自然', color: '#81C784', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // 緑系
    TagEntity(name: '名言', color: '#64B5F6', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // 青系
    TagEntity(name: '季節', color: '#FFD54F', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // 黄系
    TagEntity(name: '歴史', color: '#BA68C8', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // 紫系
    TagEntity(name: '人生訓', color: '#E57373', createdAt: DateTime.now(), updatedAt: DateTime.now()),   // 赤系
    TagEntity(name: '感情', color: '#4DB6AC', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // エメラルド系
    TagEntity(name: '哲学', color: '#9575CD', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // ラベンダー
    TagEntity(name: '文学', color: '#A1887F', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // ブラウン
    TagEntity(name: '友情', color: '#F06292', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // ピンク
    TagEntity(name: '努力', color: '#FF8A65', createdAt: DateTime.now(), updatedAt: DateTime.now()),     // オレンジ
  ];


  final tagIds = <int>[];
  for (final t in tags) {
    final id = await tagRepo.insertTag(t);
    tagIds.add(id);
  }
  
  debugPrint('✅ サンプルデータを挿入しました');
}

/// 各カードに 0〜6 個のタグをランダムに付与する
Future<void> attachRandomTags() async {
  final cardRepo = CardRepository.instance;
  final tagRepo = TagRepository.instance;
  final cardTagRepo = CardTagRepository.instance;
  final rnd = Random();

  // すべてのカードとタグを取得
  final cards = await cardRepo.getCards();
  final tags = await tagRepo.getTags();

  if (cards.isEmpty || tags.isEmpty) {
    debugPrint('⚠️ カードまたはタグが存在しません。先に insertSampleData() を実行してください。');
    return;
  }

  debugPrint('📘 カード数: ${cards.length}, 🏷️ タグ数: ${tags.length}');
  int attachCount = 0;

  // 各カードに対して 0〜6 個のタグをランダム付与
  for (final card in cards) {
    final tagCount = rnd.nextInt(7); // 0〜6
    if (tagCount == 0) continue;

    // 重複しないようにランダム抽出
    final shuffled = [...tags]..shuffle(rnd);
    final selectedTags = shuffled.take(tagCount).toList();

    for (final tag in selectedTags) {
      await cardTagRepo.attachTag(card.id!, tag.id!);
      attachCount++;
    }
  }

  debugPrint('✅ ランダムタグ付与完了: 総ペア数 $attachCount 件');
}