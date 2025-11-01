bool isVeryShort(String hira) => hira.runes.length < 2;

Iterable<String> toks(String s) =>
    s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);

final _ftsUnsafe = RegExp(r'''['*():+\-~^]+'''); 
// ここで " は落とさない（後で二重化して安全化）
// : はフィールド指定対策で除去

String escapeFtsToken(String token, {int maxLen = 32}) {
  var t = token.trim();

  // 空白除去（トークン内空白は構文に影響する）
  t = t.replaceAll(RegExp(r'\s+'), '');

  // 危険記号を除去
  t = t.replaceAll(_ftsUnsafe, '');

  // 論理演算子単語を除外
  const kws = {'AND', 'OR', 'NOT'};
  if (kws.contains(t.toUpperCase())) return '';

  // 長すぎるトークンは切り詰め（負荷対策）
  if (t.length > maxLen) t = t.substring(0, maxLen);
  if (t.isEmpty) return '';

   // クォートが必要？（今回はシンプルに、英数・ひらがな・カタカナ・漢字のみなら不要とみなす）
  final needsQuotes = RegExp(r'[^0-9A-Za-z\u3040-\u30FF\u4E00-\u9FFF]').hasMatch(t);

  if (needsQuotes) {
    t = t.replaceAll('"', '""');       // クォート内の " をエスケープ
    return '"$t*"';                    // ★ クォートの“中”に *
  } else {
    return '$t*';                      // ★ クォートなしで *
  }
}

String escapeLike(String s) {
  var out = s.replaceAll('\\', '\\\\'); // まず \
  out = out.replaceAll('%', '\\%');     // 次に %
  out = out.replaceAll('_', '\\_');     // 最後に _
  return out;
}

String colExpr(String col, Iterable<String> rawTokens, {int maxTokens = 8}) {
  final toksSafe = rawTokens
      .map(escapeFtsToken)          // ← ここで "語句クォート + *" にする
      .where((t) => t.isNotEmpty)
      .take(maxTokens)
      .toList();
  if (toksSafe.isEmpty) return '';
  // 例: name:"東京"* "駅"*
  return toksSafe.map((t) => '$col:$t').join(' ');
}

String sanitizeSimple(String input) {
  return input
    .replaceAll("'", "’")
    .replaceAll('"', '”')
    .replaceAll(";", "；")
    .replaceAll("--", "—")
    .trim();
}