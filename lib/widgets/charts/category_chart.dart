import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/currency_formatter.dart';
import '../../utils/statistics_calculator.dart';
import '../empty_state.dart';

/// Diagram donat per kategori (total di tengah) + daftar dengan bar progres.
class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key, required this.data});

  final List<CategoryTotal> data;

  String _percent(int part, int sum) =>
      '${(part * 100 / sum).toStringAsFixed(1).replaceAll('.', ',')}%';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sum = data.fold<int>(0, (s, c) => s + c.total);

    if (sum == 0) {
      return const SizedBox(
        height: 200,
        child: EmptyState(
          icon: Icons.pie_chart_outline,
          message: 'Belum ada pengeluaran pada bulan ini.',
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  sections: [
                    for (final c in data)
                      PieChartSectionData(
                        value: c.total.toDouble(),
                        color: c.category.color,
                        radius: 40,
                        // Persentase kecil tidak dituliskan agar tidak bertumpuk.
                        title: c.total * 100 / sum >= 8
                            ? '${(c.total * 100 / sum).round()}%'
                            : '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 96,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: scheme.outline, fontSize: 12),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(sum),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final c in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: c.category.color.withValues(alpha: 0.15),
                      child:
                          Icon(c.category.icon, size: 18, color: c.category.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.category.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(c.total),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: c.total / sum,
                          minHeight: 6,
                          color: c.category.color,
                          backgroundColor:
                              c.category.color.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: Text(
                        _percent(c.total, sum),
                        textAlign: TextAlign.right,
                        style: TextStyle(color: scheme.outline, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}