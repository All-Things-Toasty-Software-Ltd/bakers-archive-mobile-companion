/// Helper utilities for Baker's Math and ingredient scaling.
class BakersMath {
  BakersMath._();

  /// Parse baker percentage from string like "80% in Baker's math." or "100%"
  static double? extractPercentage(String text) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*%\s*(?:in\s+Baker)?', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Scale ingredient quantity according to multiplier
  static double scaleQuantity(double baseQuantity, double multiplier) {
    if (multiplier <= 0) return baseQuantity;
    return baseQuantity * multiplier;
  }

  /// Format quantity gracefully (e.g. 400 instead of 400.0, 1.5 instead of 1.50)
  static String formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  /// Format minutes into human-readable duration (e.g. 5 min, 1h 30m, 24h)
  static String formatDurationMinutes(double minutes) {
    if (minutes <= 0) return '';
    if (minutes < 60) {
      return '${minutes.toInt()} min';
    }
    final int hours = minutes ~/ 60;
    final int remainingMins = (minutes % 60).toInt();
    if (remainingMins == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    }
    return '$hours hr $remainingMins min';
  }
}
