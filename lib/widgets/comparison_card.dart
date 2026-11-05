import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/comparison_calculator.dart';
import '../utils/currency_formatter.dart';
import '../utils/statistics_calculator.dart';

/// Kartu perbandingan bulan terpilih dengan bulan sebelumnya.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.comparison});

  final MonthComparison comparison;

  String _monthName(DateTime d) => DateFormat('MMMM yyyy', 'id_ID').format(d);

  String _percent(double p) =>
      '${p.abs().toStringAsFixed(1).replaceAll('.', ',')}%';

  @override
  Widget build(BuildContext context) {
    final c = comparison;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prevName = _monthName(c.previousMonth);

    final Color color;
    final IconData icon;
    final String headline;
    switch (c.trend) {
      case ComparisonTrend.up:
        color = scheme.error; // pengeluaran bertambah
        icon = Icons.arrow_upward;
        headline = 'Naik ${CurrencyFormatter.format(c.difference)}';
      case ComparisonTrend.down:
        color = scheme.primary; // pengeluaran berkurang
        icon = Icons.arrow_downward;
        headline = 'Turun ${CurrencyFormatter.format(-c.difference)}';
      case ComparisonTrend.same:
        color = scheme.outline;
        icon = Icons.remove;
        headline = 'Sama dengan bulan sebelumnya';
      case ComparisonTrend.noData:
        color = scheme.outline;
        icon = Icons.remove;
        headline = 'Belum ada data untuk dibandingkan';
    }

    final String? detail;
    final p = c.percentChange;
    if (c.trend == ComparisonTrend.noData) {
      detail = null;
    } else if (p == null) {
      detail = 'Tidak ada pengeluaran di $prevName sebagai pembanding.';
    } else if (c.trend == ComparisonTrend.same) {
      detail = 'Tidak ada perubahan dari $prevName.';
    } else {
      detail = '${_percent(p)} ${p > 0 ? 'lebih tinggi' : 'lebih rendah'} '
          'dari $prevName.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dibanding bulan sebelumnya', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: textTheme.titleMedium?.copyWith(
                            color: color, fontWeight: FontWeight.bold),
                      ),
                      if (detail != null) Text(detail),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _Row(label: _monthName(c.month), value: c.current),
            const SizedBox(height: 6),
            _Row(label: prevName, value: c.previous),
            const Divider(height: 28),
            Text('Kategori terbesar', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            _TopCategory(label: _monthName(c.month), top: c.topCurrent),
            const SizedBox(height: 6),
            _TopCategory(label: prevName, top: c.topPrevious),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          CurrencyFormatter.format(value),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TopCategory extends StatelessWidget {
  const _TopCategory({required this.label, required this.top});

  final String label;
  final CategoryTotal? top;

  @override
  Widget build(BuildContext context) {
    final t = top;
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        ),
        if (t == null)
          const Text('-')
        else ...[
          Icon(t.category.icon, size: 18, color: t.category.color),
          const SizedBox(width: 6),
          Text('${t.category.label} '
              '(${CurrencyFormatter.format(t.total)})'),
        ],
      ],
    );
  }
}