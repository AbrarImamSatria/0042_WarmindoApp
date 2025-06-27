import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _numberFormat = NumberFormat('#,###', 'id_ID');

  // Format number to currency string
  static String formatRupiah(num amount) {
    return _currencyFormat.format(amount);
  }

  // Format without symbol
  static String formatNumber(num amount) {
    return _numberFormat.format(amount);
  }

  // Parse currency string to number
  static int parseCurrency(String value) {
    final cleanValue = value
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '');
    return int.tryParse(cleanValue) ?? 0;
  }

  // Format for input field (thousands separator)
  static String formatInput(String value) {
    if (value.isEmpty) return '';
    
    final cleanValue = value.replaceAll('.', '');
    final number = int.tryParse(cleanValue);
    if (number == null) return value;
    
    return formatNumber(number);
  }

  // Shortened format for large numbers
  static String formatShort(num amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}rb';
    }
    return formatRupiah(amount);
  }

  // Format for display in compact form
  static String formatCompact(num amount) {
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}