String limitTextLength(String text) {
   final firstLine = text.split('\n').first;
  if (text.length > 19) {
    return '${text.substring(0, 19)}...';
  }

  if (text.contains('\n')) {
    return '$firstLine...';
  }

  return text;
}
