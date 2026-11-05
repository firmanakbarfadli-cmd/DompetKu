import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/currency_formatter.dart';
import '../../utils/statistics_calculator.dart';
import '../empty_state.dart';

/// Diagram lingkaran per kategori, lengkap dengan legenda.
class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key, required this.data});

  final List<CategoryTotal> data;

  @override
  Widget build(BuildContext context) {
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
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (final c in data)
                  PieChartSectionData(
                    value: c.total.toDouble(),
                    color: c.category.color,
                    radius: 60,
                    // Persentase kecil tidak dituliskan agar tidak bertumpuk.
                    title: c.total * 100 / sum >= 6
                        ? '${(c.total * 100 / sum).round()}%'
                        : '',
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final c in data)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(c.category.icon, color: c.category.color),
            title: Text(c.category.label),
            subtitle: Text('${(c.total * 100 / sum).toStringAsFixed(1)}%'),
            trailing: Text(
              CurrencyFormatter.format(c.total),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}