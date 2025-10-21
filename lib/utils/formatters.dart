import 'package:intl/intl.dart';

class AppFormatters {
  // Formats a double into a currency string (e.g., 1234.56 -> $1,234.56)
  static final currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
  );

  // Formats a DateTime object into a user-friendly date string (e.g., -> Oct 15, 2025)
  static final dateFormatter = DateFormat.yMMMd();

  // Formats a DateTime object into a shorter month-day string (e.g., -> Oct 15)
  static final shortDateFormatter = DateFormat.MMMd();
}
