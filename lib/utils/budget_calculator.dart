import '../models/monthly_budget.dart';

enum BudgetStatus { notSet, safe, warning, exhausted, exceeded }

/// Hasil perhitungan budget untuk satu bulan.
class BudgetSummary {
  const BudgetSummary({
    required this.status,
    required this.budget,
    required this.spent,
  });

  final BudgetStatus status;
  final int budget; // 0 jika belum diatur / nonaktif
  final int spent;

  bool get isActive => status != BudgetStatus.notSet;

  /// Bisa negatif jika pengeluaran melampaui budget.
  int get remaining => budget - spent;

  /// Persentase pemakaian. 0 jika budget belum diatur (tidak ada bagi nol).
  double get percent => budget > 0 ? spent * 100 / budget : 0;

  /// Nilai 0.0 - 1.0 untuk progress bar.
  double get progress => (percent / 100).clamp(0.0, 1.0).toDouble();
}

class BudgetCalculator {
  BudgetCalculator._();

  /// Ambang peringatan, dalam persen.
  static const int warningPercent = 80;

  static BudgetSummary compute({
    required MonthlyBudget? budget,
    required int spent,
  }) {
    if (budget == null || !budget.isActive || budget.amount <= 0) {
      return BudgetSummary(
        status: BudgetStatus.notSet,
        budget: 0,
        spent: spent,
      );
    }

    final b = budget.amount;
    final BudgetStatus status;
    if (spent > b) {
      status = BudgetStatus.exceeded;
    } else if (spent == b) {
      status = BudgetStatus.exhausted;
    } else if (spent * 100 >= b * warningPercent) {
      status = BudgetStatus.warning;
    } else {
      status = BudgetStatus.safe;
    }
    return BudgetSummary(status: status, budget: b, spent: spent);
  }
}