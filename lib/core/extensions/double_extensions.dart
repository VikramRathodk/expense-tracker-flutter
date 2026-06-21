import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toCurrencyString(String currencyCode) {
    final format = NumberFormat.currency(
      symbol: _symbolFor(currencyCode),
      decimalDigits: 2,
    );
    return format.format(this);
  }

  String toCompactCurrency(String currencyCode) {
    return '${_symbolFor(currencyCode)}${_compactNumber()}';
  }

  String _compactNumber() {
    final abs = this.abs();
    if (abs >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(2);
  }

  static String _symbolFor(String code) {
    return const {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'SGD': 'S\$',
      'AED': 'د.إ',
      'CHF': 'Fr',
    }[code] ??
        code;
  }
}
