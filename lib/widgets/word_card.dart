import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {

  final String name;
  final String intro;
  final String updatedAt;

  const WordCard({
    super.key,
    required this.name,
    required this.intro,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(intro),
        trailing: Text(updatedAt),
      ),
    );
  }
}