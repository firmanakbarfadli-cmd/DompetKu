import 'package:dompetku/models/expense.dart';
import 'package:dompetku/models/expense_category.dart';
import 'package:dompetku/services/csv_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _e(String title, int amount, {String? note}) => Expense(
      id: 1,
      title: title,
      amount: amount,
      category: ExpenseCategory.food,
      date: DateTime(2026, 10, 5),
      note: note,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  test('header, baris data, dan baris total', () {
    final csv = CsvExportService.build([_e('Makan', 25000), _e('Kopi', 15000)]);
    expect(csv.startsWith('\uFEFF'), true);
    expect(csv.contains('Tanggal,Nama,Kategori,Nominal (Rp),Catatan'), true);
    expect(csv.contains('2026-10-05,Makan,Makanan,25000,'), true);
    expect(csv.contains(',TOTAL,,40000,'), true);
  });

  test('koma dan tanda kutip di-escape', () {
    final csv = CsvExportService.build([_e('Kopi, susu', 1000, note: 'Dia "bilang" ok')]);
    expect(csv.contains('"Kopi, susu"'), true);
    expect(csv.contains('"Dia ""bilang"" ok"'), true);
  });

  test('awalan rumus dinetralkan', () {
    final csv = CsvExportService.build([_e('=1+1', 1000)]);
    expect(csv.contains("'=1+1"), true);
  });

  test('daftar kosong: hanya header dan total 0', () {
    final csv = CsvExportService.build([]);
    expect(csv.contains(',TOTAL,,0,'), true);
  });
}