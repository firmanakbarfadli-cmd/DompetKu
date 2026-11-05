import '../models/expense.dart';
import '../utils/date_helper.dart';

class CsvExportService {
  CsvExportService._();

  static const header = [
    'Tanggal',
    'Nama',
    'Kategori',
    'Nominal (Rp)',
    'Catatan',
  ];

  /// Memberi tanda kutip jika perlu, dan menetralkan awalan rumus.
  static String _cell(String value) {
    var s = value;
    if (s.isNotEmpty && '=+-@\t\r'.contains(s[0])) {
      s = "'$s";
    }
    final needsQuote = s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r');
    if (needsQuote) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<String> cells) => cells.map(_cell).join(',');

  /// Mengembalikan isi file CSV (diawali BOM agar Excel membaca UTF-8).
  static String build(List<Expense> expenses) {
    final lines = <String>[_row(header)];
    var total = 0;
    for (final e in expenses) {
      total += e.amount;
      lines.add(_row([
        DateHelper.toDbDate(e.date),
        e.title,
        e.category.label,
        e.amount.toString(), // angka polos
        e.note ?? '',
      ]));
    }
    lines.add(_row(['', 'TOTAL', '', total.toString(), '']));
    return '\uFEFF${lines.join('\r\n')}\r\n';
  }
}