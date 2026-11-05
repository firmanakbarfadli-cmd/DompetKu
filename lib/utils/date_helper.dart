import 'package:intl/intl.dart';

/// Helper untuk mengubah tanggal dari/ke format yang disimpan di database
/// dan untuk menampilkannya ke pengguna.
class DateHelper {
  DateHelper._();

  /// DateTime -> "2026-10-24"
  static String toDbDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// "2026-10-24" -> DateTime (jam 00:00)
  static DateTime fromDbDate(String s) {
    final p = s.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  /// DateTime -> "2026-10" (kunci budget bulanan)
  static String toYearMonth(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  /// Tanggal 1 pada bulan dari [d].
  static DateTime monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  /// Tanggal 1 pada bulan berikutnya (batas atas query bulanan).
  static DateTime nextMonthStart(DateTime d) => DateTime(d.year, d.month + 1, 1);

  /// Untuk tampilan: "24 Okt 2026".
  /// Membutuhkan initializeDateFormatting('id_ID') di main.dart.
  static String formatDisplay(DateTime d) =>
      DateFormat('d MMM yyyy', 'id_ID').format(d);

  /// Untuk tampilan: "24 Okt 2026, 14:30".
  static String formatDateTime(DateTime d) =>
      DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
}