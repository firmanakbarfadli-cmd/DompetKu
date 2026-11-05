import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/currency_formatter.dart';
import '../empty_state.dart';

/// Grafik batang total per bulan. [months] dan [totals] urut dari terlama.
/// Batang terakhir (bulan terpilih) diberi warna penuh.
class MonthlyChart extends StatelessWidget {
  const MonthlyChart({
    super.key,
    required this.months,
    required this.totals,
    this.height = 200,
  });

  final List<DateTime> months;
  final List<int> totals;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxVal = totals.fold<int>(0, (m, v) => v > m ? v : m);

    if (maxVal == 0) {
      return SizedBox(
        height: height,
        child: const EmptyState(
          icon: Icons.bar_chart,
          message: 'Belum ada pengeluaran pada 6 bulan terakhir.',
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.15,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= months.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MMM', 'id_ID').format(months[i]),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label =
                    DateFormat('MMMM yyyy', 'id_ID').format(months[group.x]);
                return BarTooltipItem(
                  '$label\n${CurrencyFormatter.format(rod.toY.round())}',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < totals.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: totals[i].toDouble(),
                    color: i == totals.length - 1
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.4),
                    width: 22,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}