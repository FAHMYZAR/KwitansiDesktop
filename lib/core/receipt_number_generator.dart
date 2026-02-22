import '../models/app_settings.dart';

class ReceiptNumberGenerator {
  static String generate(AppSettings settings) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();

    return settings.receiptFormat
        .replaceAll('{counter}', settings.receiptCounter.toString())
        .replaceAll('{prefix}', settings.receiptPrefix)
        .replaceAll('{month}', month)
        .replaceAll('{year}', year);
  }
}
