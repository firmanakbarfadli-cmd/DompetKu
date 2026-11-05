import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/currency_formatter.dart';
import '../empty_state.dart';

/// Grafik batang pengeluaran per hari. [totals][0] = tanggal 1.
class DailyChart extends StatelessWidget {
  const DailyChart({super.key, required this.totals, this.height = 200});

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
          message: 'Belum ada pengeluaran pada bulan ini.',
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.15,
          alignment: BarChartAlignment.spaceBetween,
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
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final d = value.toInt();
                  if (d != 1 && d % 5 != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('$d', style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Tgl ${group.x}\n${CurrencyFormatter.format(rod.toY.round())}',
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
                x: i + 1,
                barRods: [
                  BarChartRodData(
                    toY: totals[i].toDouble(),
                    color: scheme.primary,
                    width: 5,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}