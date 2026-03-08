/// Extension methods on [num] for formatting.
extension NumExtensions on num {
  String get asCurrency => 'Rs. ${toStringAsFixed(2)}';

  String get asCompactCurrency {
    if (this >= 100000) {
      return 'Rs. ${(this / 100000).toStringAsFixed(1)}L';
    } else if (this >= 1000) {
      return 'Rs. ${(this / 1000).toStringAsFixed(1)}K';
    }
    return asCurrency;
  }

  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
}
