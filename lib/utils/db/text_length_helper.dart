String limitTextLength(String text) {
  if (text.length > 19) {
    return '${text.substring(0, 19)}...';
  }
  return text;
}
