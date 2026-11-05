import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/comparison_calculator.dart';
import '../utils/currency_formatter.dart';
import '../utils/statistics_calculator.dart';
import '../widgets/budget_card.dart';
import '../widgets/charts/daily_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import 'budget_screen.dart';
import 'expense_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final all = provider.expenses;
    final now = DateTime.now();

    final monthItems = StatisticsCalculator.inMonth(all, now);
    final total = StatisticsCalculator.total(monthItems);
    final comparison = ComparisonCalculator.compare(all, now);
    final categories = StatisticsCalculator.categoryTotals(all, now);
    final avgPerDay = total ~/ now.day; // now.day minimal 1
    final recent = provider.recent;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('DompetKu')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                _HeroCard(
                  month: now,
                  total: total,
                  comparison: comparison,
                ),
                const SizedBox(height: 12),
                                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.receipt_long,
                          label: 'Transaksi',
                          value: '${monthItems.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.today,
                          label: 'Rata-rata/hari',
                          value: CurrencyFormatter.format(avgPerDay),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: categories.isEmpty
                              ? Icons.category_outlined
                              : categories.first.category.icon,
                          iconColor: categories.isEmpty
                              ? null
                              : categories.first.category.color,
                          label: 'Terbanyak',
                          value: categories.isEmpty
                              ? '-'
                              : categories.first.category.label,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BudgetCard(
                  month: now,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengeluaran harian',
                            style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        DailyChart(
                          totals:
                              StatisticsCalculator.dailyTotals(all, now),
                          height: 140,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Transaksi terbaru', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                if (recent.isEmpty)
                  const SizedBox(
                    height: 220,
                    child: EmptyState(
                      icon: Icons.receipt_long,
                      message:
                          'Belum ada transaksi.\nTekan tombol Tambah untuk mencatat.',
                    ),
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < recent.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, indent: 72, endIndent: 16),
                          ExpenseTile(
                            expense: recent[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailScreen(
                                    expenseId: recent[i].id!),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Kartu utama bergradasi: total pengeluaran + perbandingan bulan lalu.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.month,
    required this.total,
    required this.comparison,
  });

  final DateTime month;
  final int total;
  final MonthComparison comparison;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF166534), Color(0xFF0F2A1A)]
        : const [Color(0xFF16A34A), Color(0xFF166534)];
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pengeluaran bulan ini',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const Spacer(),
              Text(
                monthLabel,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _CompareChip(comparison: comparison),
        ],
      ),
    );
  }
}

class _CompareChip extends StatelessWidget {
  const _CompareChip({required this.comparison});

  final MonthComparison comparison;

  @override
  Widget build(BuildContext context) {
    final c = comparison;
    final p = c.percentChange;

    final IconData icon;
    final Color color;
    final String text;

    if (c.trend == ComparisonTrend.noData) {
      icon = Icons.remove;
      color = Colors.white70;
      text = 'Belum ada data';
    } else if (p == null) {
      icon = Icons.info_outline;
      color = Colors.white70;
      text = 'Belum ada pembanding bulan lalu';
    } else if (c.trend == ComparisonTrend.same) {
      icon = Icons.remove;
      color = Colors.white70;
      text = 'Sama dengan bulan lalu';
    } else if (c.trend == ComparisonTrend.up) {
      icon = Icons.arrow_upward;
      color = const Color(0xFFFCA5A5); // pengeluaran naik
      text = '${p.abs().toStringAsFixed(1).replaceAll('.', ',')}% '
          'vs bulan lalu';
    } else {
      icon = Icons.arrow_downward;
      color = const Color(0xFF86EFAC); // pengeluaran turun
      text = '${p.abs().toStringAsFixed(1).replaceAll('.', ',')}% '
          'vs bulan lalu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kecil untuk angka ringkas.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor ?? scheme.primary),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(color: scheme.outline, fontSize: 11)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}