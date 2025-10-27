import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WordSelectionController<T> extends ChangeNotifier {
  bool selectionMode = false;
  final Set<T> selectedIds = <T>{};

  void enterAndSelect(T id) {
    selectionMode = true;
    toggle(id);
  }

  void toggle(T id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void exit() {
    selectionMode = false;
    selectedIds.clear();
    notifyListeners();
  }

  void pruneNotVisible(Set<T> visible) {
    final before = selectedIds.length;
    selectedIds.removeWhere((id) => !visible.contains(id));
    if (selectedIds.length != before) {
      notifyListeners(); //ChangeNotifierに登録されたすべてのリスナーへ「状態が変わったよ！」と通知するメソッド
    }
  }

  int get count => selectedIds.length;
}