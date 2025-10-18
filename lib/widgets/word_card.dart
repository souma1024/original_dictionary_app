import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {

  final String name;
  final String intro;

  const WordCard({
    super.key,
    required this.name,
    required this.intro
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(intro),
      ),
    );
  }
}