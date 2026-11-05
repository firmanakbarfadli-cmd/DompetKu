import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/budget_calculator.dart';
import '../utils/currency_formatter.dart';

/// Kartu ringkasan budget untuk satu bulan.
/// Jika [onTap] diisi, kartu bisa diketuk (dipakai di Beranda).
class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.month, this.onTap});

  final DateTime month;
  final VoidCallback? onTap;

  static Color statusColor(BuildContext context, BudgetStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case BudgetStatus.safe:
        return scheme.primary;
      case BudgetStatus.warning:
        return Colors.orange;
      case BudgetStatus.exhausted:
      case BudgetStatus.exceeded:
        return scheme.error;
      case BudgetStatus.notSet:
        return scheme.outline;
    }
  }

  static String statusLabel(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return 'Terkendali';
      case BudgetStatus.warning:
        return 'Hampir habis';
      case BudgetStatus.exhausted:
        return 'Budget habis';
      case BudgetStatus.exceeded:
        return 'Terlampaui';
      case BudgetStatus.notSet:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>().budgetFor(month);
    final spent = context.watch<ExpenseProvider>().totalForMonth(month);
    final s = BudgetCalculator.compute(budget: budget, spent: spent);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Budget belum diatur atau dinonaktifkan: jangan tampilkan nominal.
    if (!s.isActive) {
      final wasDisabled = budget != null && !budget.isActive;
      final String hint;
      if (onTap == null) {
        hint = 'Isi nominal di bawah untuk mengaktifkan budget.';
      } else if (wasDisabled) {
        hint = 'Ketuk untuk mengaktifkannya kembali.';
      } else {
        hint = 'Ketuk untuk mengatur budget bulanan (opsional).';
      }
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.savings_outlined, size: 32, color: scheme.outline),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wasDisabled
                            ? 'Budget dinonaktifkan'
                            : 'Budget belum diatur',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(hint),
                    ],
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );
    }

    final color = statusColor(context, s.status);
    final over = s.remaining < 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Budget bulanan'),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel(s.status),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                over
                    ? 'Terlampaui ${CurrencyFormatter.format(-s.remaining)}'
                    : 'Sisa ${CurrencyFormatter.format(s.remaining)}',
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: s.progress,
                  minHeight: 10,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 8),
              // floor(): 79,9% tidak tampil sebagai 80% saat status masih aman.
              Text(
                'Terpakai ${CurrencyFormatter.format(s.spent)} dari '
                '${CurrencyFormatter.format(s.budget)} (${s.percent.floor()}%)',
              ),
            ],
          ),
        ),
      ),
    );
  }
}