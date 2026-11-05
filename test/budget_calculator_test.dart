import 'package:dompetku/models/monthly_budget.dart';
import 'package:dompetku/utils/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

MonthlyBudget _budget(int amount, {bool active = true}) => MonthlyBudget(
      yearMonth: '2026-10',
      amount: amount,
      isActive: active,
      updatedAt: DateTime(2026, 10, 1),
    );

void main() {
  group('BudgetCalculator', () {
    test('tanpa budget -> notSet, tidak ada bagi nol', () {
      final s = BudgetCalculator.compute(budget: null, spent: 50000);
      expect(s.status, BudgetStatus.notSet);
      expect(s.isActive, false);
      expect(s.percent, 0);
    });

    test('budget dinonaktifkan -> notSet', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000, active: false), spent: 500000);
      expect(s.status, BudgetStatus.notSet);
    });

    test('budget bernilai 0 -> notSet, tidak crash', () {
      final s = BudgetCalculator.compute(budget: _budget(0), spent: 1000);
      expect(s.status, BudgetStatus.notSet);
      expect(s.percent, 0);
    });

    test('pemakaian 50% -> safe', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000), spent: 500000);
      expect(s.status, BudgetStatus.safe);
      expect(s.remaining, 500000);
      expect(s.percent, 50);
    });

    test('799.999 dari 1.000.000 -> masih safe', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000), spent: 799999);
      expect(s.status, BudgetStatus.safe);
    });

    test('tepat 80% -> warning', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000), spent: 800000);
      expect(s.status, BudgetStatus.warning);
    });

    test('tepat habis -> exhausted, sisa 0', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000), spent: 1000000);
      expect(s.status, BudgetStatus.exhausted);
      expect(s.remaining, 0);
    });

    test('melampaui -> exceeded, sisa negatif, progress dibatasi 1.0', () {
      final s = BudgetCalculator.compute(
          budget: _budget(1000000), spent: 1200000);
      expect(s.status, BudgetStatus.exceeded);
      expect(s.remaining, -200000);
      expect(s.percent, 120);
      expect(s.progress, 1.0);
    });

    test('belum ada pengeluaran -> safe, sisa penuh', () {
      final s = BudgetCalculator.compute(budget: _budget(500000), spent: 0);
      expect(s.status, BudgetStatus.safe);
      expect(s.remaining, 500000);
    });
  });
}