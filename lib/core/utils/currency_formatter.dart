import 'package:intl/intl.dart';

/// Currency formatting helpers.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _nprFormat = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static String formatNPR(double amount) {
    return _nprFormat.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'Rs. ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatNPR(amount);
  }

  static String formatDiscount(double percent) {
    return '${percent.toStringAsFixed(0)}% OFF';
  }
}
