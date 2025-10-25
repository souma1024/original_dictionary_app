import 'package:flutter/material.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  
  @override
  Widget build(BuildContext context) {
    return const CommonScaffold(
      title: 'クイズ',
      body: Center(child: Text('クイズ画面')),
    );
  }

}