import 'package:intl/intl.dart';

String numberFormat(int num) {
  final formatter = NumberFormat("#,###");
  return formatter.format(num);
}
