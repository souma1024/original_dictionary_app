import 'package:original_dict_app/models/card_entity.dart';

class CardHit {
  final CardEntity card;
  final String? snippet; // ハイライト付き抜粋
  CardHit({required this.card, this.snippet});
}