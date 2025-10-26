import 'package:flutter/material.dart';
import 'package:original_dict_app/widgets/common_drawer.dart';

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? fab;

  const CommonScaffold({
    super.key,
    required this.body,
    required this.title,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const CommonDrawer(),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}