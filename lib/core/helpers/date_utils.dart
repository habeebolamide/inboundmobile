import 'package:intl/intl.dart';

String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
  return DateFormat(pattern).format(date);
}

String formatTime(DateTime time) {
  return DateFormat.Hm().format(time);
}
