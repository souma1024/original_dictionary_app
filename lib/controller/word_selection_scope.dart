import 'package:flutter/material.dart';
import 'package:original_dict_app/controller/word_collection_controller.dart';

class WordSelectionScope<T> extends InheritedNotifier<WordSelectionController<T>> {

  const WordSelectionScope({
    super.key,
    required WordSelectionController<T> controller,
    required super.child,
  }) : super(notifier: controller);

  static WordSelectionController<T> of<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WordSelectionScope<T>>();
    assert(scope != null, 'WordSelectionScope<$T> not found in widget tree.');
    return scope!.notifier!;
  }
}
