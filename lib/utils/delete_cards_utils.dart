import 'package:flutter/foundation.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/controller/word_selection_controller.dart';

class DeleteCardsUtils {
  final CardRepository repo;
  final WordSelectionController<int> selection;
  final VoidCallback onReload; // 画面に「再取得して」と伝えるだけ

  DeleteCardsUtils({
    required this.repo,
    required this.selection,
    required this.onReload,
  });

  Future<void> call(List<int> ids) async {
    if (ids.isEmpty) return;
    await repo.deleteCards(ids);
    selection.exit();
    onReload();
  }
}