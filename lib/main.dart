import 'package:flutter/material.dart';
import 'package:original_dict_app/screens/home/home_screen.dart';
import 'package:original_dict_app/screens/quiz/quiz_screen.dart';
import 'package:original_dict_app/screens/wordlist/word_list_screen.dart';
// import 'package:original_dict_app/data/app_database.dart';


void main() {
  // WidgetsFlutterBinding.ensureInitialized(); テーブル設計を変更したときのみ有効にする
  // await AppDatabase.instance.resetForDev();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 画面右上に表示されるリボン型でDEBUGと書いてあるものを非表示にする
      debugShowCheckedModeBanner: false,
      title: 'オリジナル辞書アプリ',

      // fromSeedでseedColorを基調にした統一感あるデザインが自動で作れる
      // useMaterial3:trueで、デザインをMaterial design3という最新バージョンにする
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/words': (_) => const WordListScreen()
      },
    );
  }
}