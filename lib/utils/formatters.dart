import 'package:intl/intl.dart';

class Formatters {
  static String currency(num value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }
}
