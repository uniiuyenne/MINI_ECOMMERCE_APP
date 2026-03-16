import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String currency(double value) {
    return _vnd.format(value);
  }

  static String soldCount(int count) {
    if (count >= 1000000) {
      return 'Đã bán ${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return 'Đã bán ${(count / 1000).toStringAsFixed(1)}k';
    }
    return 'Đã bán $count';
  }

  static String dateTime(DateTime value) {
    return _dateTime.format(value);
  }
}
