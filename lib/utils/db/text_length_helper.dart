
class TextLengthHelper {
  static String limitTextLength(String text) {

    if (text.length > 30) {
      return '${text.substring(0, 30)}....';
    }
    return text;
  }
}