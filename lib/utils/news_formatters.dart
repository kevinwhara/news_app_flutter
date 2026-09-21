import 'package:timeago/timeago.dart' as timeago;

abstract final class NewsFormatters {
  static String publishedTime(String? value) {
    if (value == null || value.isEmpty) return 'Recently';
    final parsed = DateTime.tryParse(value);
    return parsed == null ? 'Recently' : timeago.format(parsed);
  }
}
