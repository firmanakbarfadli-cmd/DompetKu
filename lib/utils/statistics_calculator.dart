import '../models/expense.dart';
import '../models/expense_category.dart';

class CategoryTotal {
  const CategoryTotal(this.category, this.total);
  final ExpenseCategory category;
  final int total;
}

class StatisticsCalculator {
  StatisticsCalculator._();

  static List<Expense> inMonth(List<Expense> all, DateTime month) => all
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  static int total(List<Expense> list) =>
      list.fold<int>(0, (sum, e) => sum + e.amount);

  /// Jumlah hari dalam bulan (28-31). Hari ke-0 bulan depan = hari terakhir bulan ini.
  static int daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;

  /// Total per hari. Indeks 0 = tanggal 1.
  static List<int> dailyTotals(List<Expense> all, DateTime month) {
    final result = List<int>.filled(daysInMonth(month), 0);
    for (final e in inMonth(all, month)) {
      result[e.date.day - 1] += e.amount;
    }
    return result;
  }

  /// [count] bulan yang berakhir di [endMonth], urut dari yang terlama.
  static List<DateTime> monthsEnding(DateTime endMonth, {int count = 6}) {
    return List.generate(
      count,
      (i) => DateTime(endMonth.year, endMonth.month - (count - 1 - i), 1),
    );
  }

  /// Total per bulan, urutannya sama dengan [monthsEnding].
  static List<int> monthlyTotals(List<Expense> all, DateTime endMonth,
      {int count = 6}) {
    return monthsEnding(endMonth, count: count)
        .map((m) => total(inMonth(all, m)))
        .toList();
  }

  /// Total per kategori pada bulan itu, terbesar di atas. Kategori kosong dibuang.
  static List<CategoryTotal> categoryTotals(List<Expense> all, DateTime month) {
    final map = <ExpenseCategory, int>{};
    for (final e in inMonth(all, month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    final list = map.entries.map((e) => CategoryTotal(e.key, e.value)).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}