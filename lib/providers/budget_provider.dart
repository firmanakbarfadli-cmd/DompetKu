import 'package:flutter/foundation.dart';

import '../database/budget_repository.dart';
import '../models/monthly_budget.dart';
import '../utils/date_helper.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({BudgetRepository? repository})
      : _repo = repository ?? BudgetRepository();

  final BudgetRepository _repo;
  final Map<String, MonthlyBudget> _budgets = {};
  String? _error;

  String? get error => _error;

  /// Budget untuk bulan dari [month], atau null jika belum pernah diatur.
  MonthlyBudget? budgetFor(DateTime month) =>
      _budgets[DateHelper.toYearMonth(month)];

  /// Budget bulan sebelumnya, untuk fitur "Salin dari bulan lalu".
  MonthlyBudget? previousOf(DateTime month) =>
      budgetFor(DateTime(month.year, month.month - 1, 1));

  Future<void> load() async {
    try {
      final list = await _repo.getAll();
      _budgets
        ..clear()
        ..addEntries(list.map((b) => MapEntry(b.yearMonth, b)));
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat budget: $e';
    }
    notifyListeners();
  }

  /// Menetapkan atau mengubah nominal budget bulan ini. Otomatis aktif.
  Future<bool> setBudget(DateTime month, int amount) {
    return _save(MonthlyBudget(
      yearMonth: DateHelper.toYearMonth(month),
      amount: amount,
      isActive: true,
      updatedAt: DateTime.now(),
    ));
  }

  /// Mengaktifkan/menonaktifkan budget tanpa mengubah nominal dan transaksi.
  Future<bool> setActive(DateTime month, bool active) {
    final current = budgetFor(month);
    if (current == null) return Future.value(false);
    return _save(current.copyWith(isActive: active, updatedAt: DateTime.now()));
  }

  /// Menyalin nominal dari bulan sebelumnya. False jika tidak ada yang disalin.
  Future<bool> copyFromPreviousMonth(DateTime month) {
    final prev = previousOf(month);
    if (prev == null || prev.amount <= 0) return Future.value(false);
    return setBudget(month, prev.amount);
  }

  Future<bool> _save(MonthlyBudget budget) async {
    try {
      await _repo.upsert(budget);
      _budgets[budget.yearMonth] = budget;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan budget: $e';
      notifyListeners();
      return false;
    }
  }
}