import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../utils/date_helper.dart';
import '../utils/expense_filter.dart';

/// Menampilkan panel filter. Mengembalikan filter baru jika "Terapkan" ditekan.
Future<ExpenseFilter?> showFilterSheet(
    BuildContext context, ExpenseFilter current) {
  return showModalBottomSheet<ExpenseFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final ExpenseFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<ExpenseCategory> _categories;
  DateTime? _from;
  DateTime? _to;
  late ExpenseSort _sort;

  @override
  void initState() {
    super.initState();
    _categories = {...widget.initial.categories};
    _from = widget.initial.from;
    _to = widget.initial.to;
    _sort = widget.initial.sort;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today,
      initialDateRange: (_from != null && _to != null)
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
    }
  }

  void _reset() {
    setState(() {
      _categories = {};
      _from = null;
      _to = null;
      _sort = ExpenseSort.dateDesc;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      ExpenseFilter(
        query: widget.initial.query, // kata kunci diatur di kolom cari
        categories: _categories,
        from: _from,
        to: _to,
        sort: _sort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall;
    final hasRange = _from != null && _to != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori', style: labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((c) {
                final selected = _categories.contains(c);
                return FilterChip(
                  avatar: Icon(c.icon, size: 18, color: c.color),
                  label: Text(c.label),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    v ? _categories.add(c) : _categories.remove(c);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Rentang tanggal', style: labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(hasRange
                        ? '${DateHelper.formatDisplay(_from!)} - '
                            '${DateHelper.formatDisplay(_to!)}'
                        : 'Pilih rentang tanggal'),
                  ),
                ),
                if (hasRange)
                  IconButton(
                    tooltip: 'Hapus rentang',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _from = null;
                      _to = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Urutkan', style: labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseSort.values.map((s) {
                return ChoiceChip(
                  label: Text(s.label),
                  selected: _sort == s,
                  onSelected: (_) => setState(() => _sort = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}