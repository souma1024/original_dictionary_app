import 'dart:collection';
import 'package:flutter/foundation.dart';

class WordSelectionController<T> extends ChangeNotifier {
  // 選択モードのON/OFF
  final ValueNotifier<bool> _inSelection = ValueNotifier<bool>(false);
  // 選択中IDの集合（新しいSetを代入して必ず通知するポリシー）
  final ValueNotifier<Set<T>> _selected = ValueNotifier<Set<T>>(<T>{});

  // 外部公開
  bool get selectionMode => _inSelection.value;
  // UnmodifiableSetViewを使うと、違うクラスで中身を書き換えられなくなる。参照はできる。
  UnmodifiableSetView<T> get selectedIds => UnmodifiableSetView(_selected.value); 
  int get count => _selected.value.length;

  // Listenables を公開
  ValueListenable<bool> get selectionModeListenable => _inSelection;
  ValueListenable<Set<T>> get selectedIdsListenable => _selected;

  final Map<T, _SelectedForIdListenable<T>> _perIdListenables = {};

  ValueListenable<bool> isSelectedListenable(T id) {
    return _perIdListenables.putIfAbsent(
      id,
      () => _SelectedForIdListenable<T>(id, _selected),
    );
  }

  // ------------- 操作系 -------------

  void enter() {
    if (!_inSelection.value) {
      _inSelection.value = true;
      notifyListeners();
    }
  }

  void exit() {
    if (_inSelection.value || _selected.value.isNotEmpty) {
      _inSelection.value = false;
      if (_selected.value.isNotEmpty) {
        _selected.value = <T>{}; // 新しいSetを入れて必ず通知
      } else {
        // 選択モードだけ変わった場合、必要に応じて上位に通知
      }
      notifyListeners();
    }
  }

  void select(T id) {
    if (!_selected.value.contains(id)) {
      final next = {..._selected.value, id}; // _selected.valueの中身をすべてコピーし、idを追加した新しいSetを作り、nextに代入。
      _selected.value = next;
      notifyListeners();
    }
  }

  void deselect(T id) {
    if (_selected.value.contains(id)) {
      final next = {..._selected.value}..remove(id); // .. は同じオブジェクトに対して続けて操作して、そのオブジェクト自体を返す記法
      _selected.value = next;
      notifyListeners();
    }
  }

  void toggle(T id) {
    if (_selected.value.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  /// 長押しなどで「モード突入＋自分を選択」
  void enterAndSelect(T id) {
    if (!_inSelection.value) {
      _inSelection.value = true;
    }
    final next = {..._selected.value, id};
    _selected.value = next;
    notifyListeners();
  }

  /// 画面上に見えていないIDを選択集合から除外（リスト更新時に呼ぶ）
  void pruneNotVisible(Set<T> visible) {
    if (_selected.value.isEmpty) return;
    final pruned = _selected.value.intersection(visible); //intersectionはSetの共通要素を取り出すa.intersection(b)でa, bの共通する要素のSetを返す
    if (pruned.length != _selected.value.length) {
      _selected.value = pruned;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // per-id listenable の接続解除
    for (final l in _perIdListenables.values) {
      l.dispose();
    }
    _perIdListenables.clear();
    _inSelection.dispose();
    _selected.dispose();
    super.dispose();
  }
}

/// 「特定IDが選ばれているか」だけを通知する派生ValueListenable
class _SelectedForIdListenable<T> implements ValueListenable<bool> {
  _SelectedForIdListenable(this._id, this._base);

  final T _id;
  final ValueNotifier<Set<T>> _base;

  bool _cached = false;
  final List<VoidCallback> _listeners = <VoidCallback>[];
  VoidCallback? _baseListener;

  @override
  bool get value => _base.value.contains(_id);

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    // 初回リスナー追加時に base へフック
    if (_baseListener == null) {
      _cached = _base.value.contains(_id);
      _baseListener = () {
        final now = _base.value.contains(_id);
        if (now != _cached) {
          _cached = now;
          // 当該IDの状態が変わった時だけ通知
          for (final l in List<VoidCallback>.from(_listeners)) {
            l();
          }
        }
      };
      _base.addListener(_baseListener!);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty && _baseListener != null) {
      _base.removeListener(_baseListener!);
      _baseListener = null;
    }
  }

  void dispose() {
    if (_baseListener != null) {
      _base.removeListener(_baseListener!);
      _baseListener = null;
    }
    _listeners.clear();
  }
}