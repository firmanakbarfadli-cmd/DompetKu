import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/comparison_calculator.dart';
import '../utils/currency_formatter.dart';
import '../utils/statistics_calculator.dart';
import '../widgets/charts/category_chart.dart';
import '../widgets/charts/daily_chart.dart';
import '../widgets/charts/monthly_chart.dart';
import '../widgets/comparison_card.dart';

enum _FlowView { daily, monthly }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _month;
  _FlowView _view = _FlowView.daily;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final all = provider.expenses;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final monthItems = StatisticsCalculator.inMonth(all, _month);
    final monthTotal = StatisticsCalculator.total(monthItems);
    final daily = StatisticsCalculator.dailyTotals(all, _month);
    final months = StatisticsCalculator.monthsEnding(_month);
    final monthly = StatisticsCalculator.monthlyTotals(all, _month);
    final categories = StatisticsCalculator.categoryTotals(all, _month);
    final comparison = ComparisonCalculator.compare(all, _month);
    final label = DateFormat('MMMM yyyy', 'id_ID').format(_month);

    final days = _isCurrentMonth
        ? DateTime.now().day
        : StatisticsCalculator.daysInMonth(_month);
    final avgPerDay = monthTotal ~/ days;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                // ---- Pemilih bulan ----
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Bulan sebelumnya',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bulan berikutnya',
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            _isCurrentMonth ? null : () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Kartu total ----
                _TotalCard(
                  total: monthTotal,
                  count: monthItems.length,
                  avgPerDay: avgPerDay,
                ),
                const SizedBox(height: 12),

                // ---- Perbandingan ----
                ComparisonCard(comparison: comparison),
                const SizedBox(height: 12),

                // ---- Alur pengeluaran ----
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alur pengeluaran',
                            style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<_FlowView>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: _FlowView.daily,
                                icon: Icon(Icons.bar_chart),
                                label: Text('Harian'),
                              ),
                              ButtonSegment(
                                value: _FlowView.monthly,
                                icon: Icon(Icons.calendar_view_month),
                                label: Text('Bulanan'),
                              ),
                            ],
                            selected: {_view},
                            onSelectionChanged: (s) =>
                                setState(() => _view = s.first),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _view == _FlowView.daily
                              ? 'Per hari pada $label'
                              : '6 bulan sampai $label',
                          style: TextStyle(color: scheme.outline, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        if (_view == _FlowView.daily)
                          DailyChart(totals: daily)
                        else
                          MonthlyChart(months: months, totals: monthly),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Kategori ----
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Berdasarkan kategori',
                            style: textTheme.titleMedium),
                        const SizedBox(height: 16),
                        CategoryChart(data: categories),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Kartu total bergradasi untuk bulan terpilih.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.total,
    required this.count,
    required this.avgPerDay,
  });

  final int total;
  final int count;
  final int avgPerDay;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF166534), Color(0xFF0F2A1A)]
        : const [Color(0xFF16A34A), Color(0xFF166534)];
    final soft = Colors.white.withValues(alpha: 0.75);

    Widget stat(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: soft, fontSize: 12)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );

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
          Text('Total pengeluaran', style: TextStyle(color: soft)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              stat('Transaksi', '$count'),
              stat('Rata-rata/hari', CurrencyFormatter.format(avgPerDay)),
            ],
          ),
        ],
      ),
    );
  }
}