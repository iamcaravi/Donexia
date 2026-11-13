import 'package:intl/intl.dart';

String formatInr(double amount) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(amount);

String formatDate(DateTime date) =>
    DateFormat('dd MMM yyyy').format(date);
