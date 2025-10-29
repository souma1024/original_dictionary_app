import 'package:original_dict_app/dto/card_preview.dart';

class CardHit {
  final CardPreview card;
  final String? snippet; // ハイライト付き抜粋
  CardHit({required this.card, this.snippet});
  // 便利: Map から安全に生成
  factory CardHit.fromMap(Map<String, dynamic> m, {String? snippet}) {
    return CardHit(card: CardPreview.fromMap(m), snippet: snippet);
  }
}