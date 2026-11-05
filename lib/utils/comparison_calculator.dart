import '../models/expense.dart';
import 'statistics_calculator.dart';

enum ComparisonTrend { up, down, same, noData }

class MonthComparison {
  const MonthComparison({
    required this.month,
    required this.previousMonth,
    required this.current,
    required this.previous,
    required this.topCurrent,
    required this.topPrevious,
  });

  final DateTime month;
  final DateTime previousMonth;
  final int current;
  final int previous;
  final CategoryTotal? topCurrent;
  final CategoryTotal? topPrevious;

  /// Positif = naik, negatif = turun.
  int get difference => current - previous;

  /// Null jika bulan pembanding tidak punya pengeluaran (hindari bagi nol).
  double? get percentChange =>
      previous > 0 ? difference * 100 / previous : null;

  bool get hasPrevious => previous > 0;

  ComparisonTrend get trend {
    if (current == 0 && previous == 0) return ComparisonTrend.noData;
    if (difference > 0) return ComparisonTrend.up;
    if (difference < 0) return ComparisonTrend.down;
    return ComparisonTrend.same;
  }
}

class ComparisonCalculator {
  ComparisonCalculator._();

  /// Membandingkan [month] dengan bulan sebelumnya.
  static MonthComparison compare(List<Expense> all, DateTime month) {
    final m = DateTime(month.year, month.month, 1);
    final prev = DateTime(month.year, month.month - 1, 1);

    final cur = StatisticsCalculator.categoryTotals(all, m);
    final prv = StatisticsCalculator.categoryTotals(all, prev);

    return MonthComparison(
      month: m,
      previousMonth: prev,
      current: StatisticsCalculator.total(StatisticsCalculator.inMonth(all, m)),
      previous:
          StatisticsCalculator.total(StatisticsCalculator.inMonth(all, prev)),
      topCurrent: cur.isEmpty ? null : cur.first,
      topPrevious: prv.isEmpty ? null : prv.first,
    );
  }
}