import 'package:flutter/material.dart';
import 'package:original_dict_app/screens/home/home_screen.dart';
import 'package:original_dict_app/screens/quiz/quiz_screen.dart';
import 'package:original_dict_app/screens/wordlist/word_list_screen.dart';
import 'package:original_dict_app/data/app_database.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:original_dict_app/controller/word_collection_controller.dart' as collect;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← これ必須
  await AppDatabase.instance.database;      // ← DB初期化を待つ

  runApp(
    WordSelectionScope<int>(            // ★ <int> を忘れずに！
      controller: collect.WordSelectionController<int>(), // ★ ここも<int>
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'オリジナル辞書アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/words': (_) => const WordListScreen(),
      },
    );
  }
}
