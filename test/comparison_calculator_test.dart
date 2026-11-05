import 'package:dompetku/models/expense.dart';
import 'package:dompetku/models/expense_category.dart';
import 'package:dompetku/utils/comparison_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _e(int amount, DateTime date,
    [ExpenseCategory cat = ExpenseCategory.food]) {
  return Expense(
    title: 't',
    amount: amount,
    category: cat,
    date: date,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final oct = DateTime(2026, 10, 1);

  test('naik: selisih dan persentase benar', () {
    final data = [
      _e(100000, DateTime(2026, 9, 10)),
      _e(150000, DateTime(2026, 10, 3)),
    ];
    final c = ComparisonCalculator.compare(data, oct);
    expect(c.trend, ComparisonTrend.up);
    expect(c.difference, 50000);
    expect(c.percentChange, closeTo(50.0, 0.001));
  });

  test('turun: selisih negatif dan persentase negatif', () {
    final data = [
      _e(200000, DateTime(2026, 9, 10)),
      _e(150000, DateTime(2026, 10, 3)),
    ];
    final c = ComparisonCalculator.compare(data, oct);
    expect(c.trend, ComparisonTrend.down);
    expect(c.difference, -50000);
    expect(c.percentChange, closeTo(-25.0, 0.001));
  });

  test('bulan lalu kosong: persentase null, tidak crash', () {
    final c = ComparisonCalculator.compare(
        [_e(150000, DateTime(2026, 10, 3))], oct);
    expect(c.trend, ComparisonTrend.up);
    expect(c.hasPrevious, false);
    expect(c.percentChange, isNull);
  });

  test('bulan ini kosong tapi bulan lalu ada: turun 100%', () {
    final c = ComparisonCalculator.compare(
        [_e(80000, DateTime(2026, 9, 3))], oct);
    expect(c.trend, ComparisonTrend.down);
    expect(c.percentChange, closeTo(-100.0, 0.001));
  });

  test('dua bulan kosong: noData', () {
    final c = ComparisonCalculator.compare([], oct);
    expect(c.trend, ComparisonTrend.noData);
    expect(c.percentChange, isNull);
    expect(c.topCurrent, isNull);
  });

  test('total sama: same, persentase 0', () {
    final data = [
      _e(50000, DateTime(2026, 9, 10)),
      _e(50000, DateTime(2026, 10, 10)),
    ];
    final c = ComparisonCalculator.compare(data, oct);
    expect(c.trend, ComparisonTrend.same);
    expect(c.percentChange, 0);
  });

  test('Januari dibandingkan dengan Desember tahun sebelumnya', () {
    final data = [
      _e(10000, DateTime(2025, 12, 20)),
      _e(30000, DateTime(2026, 1, 5)),
    ];
    final c = ComparisonCalculator.compare(data, DateTime(2026, 1, 1));
    expect(c.previousMonth, DateTime(2025, 12, 1));
    expect(c.previous, 10000);
    expect(c.difference, 20000);
  });

  test('kategori terbesar per bulan', () {
    final data = [
      _e(20000, DateTime(2026, 10, 2), ExpenseCategory.transport),
      _e(5000, DateTime(2026, 10, 3), ExpenseCategory.food),
      _e(9000, DateTime(2026, 9, 3), ExpenseCategory.shopping),
    ];
    final c = ComparisonCalculator.compare(data, oct);
    expect(c.topCurrent!.category, ExpenseCategory.transport);
    expect(c.topPrevious!.category, ExpenseCategory.shopping);
  });
}