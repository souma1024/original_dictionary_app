import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/models/tag_entity.dart';

class HitWithTags {
  final CardHit hit;
  final List<TagEntity> tags;
  HitWithTags(this.hit, this.tags);
}