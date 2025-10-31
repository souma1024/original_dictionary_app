import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/models/card_entity.dart';

class WordDetailScreen extends StatefulWidget {
  final int cardId;

  const WordDetailScreen({super.key, required this.cardId});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  CardEntity? _card;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final card = await CardRepository.instance.getCardById(widget.cardId);
    setState(() {
      _card = card;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_card?.name ?? '読み込み中...'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _card == null
          ? const Center(child: Text('データが見つかりませんでした'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 単語名
              Text(
                _card!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 本文
              Text(
                _card!.intro,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
