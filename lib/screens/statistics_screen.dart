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

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _month;

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

    final monthTotal =
        StatisticsCalculator.total(StatisticsCalculator.inMonth(all, _month));
    final daily = StatisticsCalculator.dailyTotals(all, _month);
    final months = StatisticsCalculator.monthsEnding(_month);
    final monthly = StatisticsCalculator.monthlyTotals(all, _month);
    final categories = StatisticsCalculator.categoryTotals(all, _month);
    final comparison = ComparisonCalculator.compare(all, _month);
    final label = DateFormat('MMMM yyyy', 'id_ID').format(_month);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Bulan sebelumnya',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(label, style: textTheme.titleMedium),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bulan berikutnya',
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _isCurrentMonth ? null : () => _changeMonth(1),
                    ),
                  ],
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total pengeluaran'),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(monthTotal),
                          style: textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ComparisonCard(comparison: comparison),
                const SizedBox(height: 16),
                _Section(
                  title: 'Pengeluaran harian',
                  child: DailyChart(totals: daily),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Pengeluaran 6 bulan terakhir',
                  child: MonthlyChart(months: months, totals: monthly),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Berdasarkan kategori',
                  child: CategoryChart(data: categories),
                ),
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}