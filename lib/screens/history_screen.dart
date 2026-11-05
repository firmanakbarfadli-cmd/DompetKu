import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helper.dart';
import '../utils/expense_filter.dart';
import '../utils/statistics_calculator.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/filter_sheet.dart';
import 'expense_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  ExpenseFilter _filter = const ExpenseFilter();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final result = await showFilterSheet(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  void _clearAll() {
    _searchCtrl.clear();
    setState(() => _filter = const ExpenseFilter());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final all = provider.expenses;
    final items = _filter.apply(all);
    final showHeaders = _filter.sort.byDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Filter dan urutan',
            icon: Badge(
              isLabelVisible: _filter.hasFilters,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _openFilter,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : all.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  message: 'Belum ada transaksi tersimpan.',
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onChanged: (v) => setState(
                            () => _filter = _filter.copyWith(query: v)),
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau catatan',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Hapus pencarian',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() =>
                                        _filter = _filter.copyWith(query: ''));
                                  },
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${items.length} transaksi • '
                              '${CurrencyFormatter.format(StatisticsCalculator.total(items))}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          if (_filter.isActive)
                            TextButton(
                              onPressed: _clearAll,
                              child: const Text('Hapus filter'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off,
                              message:
                                  'Tidak ada transaksi yang cocok.\nCoba ubah kata kunci atau filter.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 88),
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final e = items[i];
                                final showHeader = showHeaders &&
                                    (i == 0 || items[i - 1].date != e.date);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 4),
                                        child: Text(
                                          DateHelper.formatDisplay(e.date),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ),
                                    ExpenseTile(
                                      expense: e,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ExpenseDetailScreen(
                                              expenseId: e.id!),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}