import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/csv_export_service.dart';
import '../services/pdf_export_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helper.dart';
import '../utils/expense_filter.dart';
import '../utils/statistics_calculator.dart';

enum _PeriodType { thisMonth, lastMonth, all, custom }

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  _PeriodType _type = _PeriodType.thisMonth;
  DateTimeRange? _custom;
  bool _busy = false;

  /// Batas periode. Keduanya null = semua transaksi.
  (DateTime?, DateTime?) get _range {
    final now = DateTime.now();
    switch (_type) {
      case _PeriodType.thisMonth:
        return (DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month + 1, 0));
      case _PeriodType.lastMonth:
        return (DateTime(now.year, now.month - 1, 1),
            DateTime(now.year, now.month, 0));
      case _PeriodType.all:
        return (null, null);
      case _PeriodType.custom:
        return (_custom?.start, _custom?.end);
    }
  }

  bool get _rangeReady =>
      _type != _PeriodType.custom || _custom != null;

  String get _label {
    final (from, to) = _range;
    switch (_type) {
      case _PeriodType.thisMonth:
      case _PeriodType.lastMonth:
        return DateFormat('MMMM yyyy', 'id_ID').format(from!);
      case _PeriodType.all:
        return 'Semua transaksi';
      case _PeriodType.custom:
        if (from == null || to == null) return 'Rentang belum dipilih';
        return '${DateHelper.formatDisplay(from)} - '
            '${DateHelper.formatDisplay(to)}';
    }
  }

  String get _fileTag {
    final (from, to) = _range;
    if (from == null || to == null) return 'semua';
    return '${DateHelper.toDbDate(from)}_${DateHelper.toDbDate(to)}';
  }

  /// Transaksi pada periode terpilih, urut dari yang terlama.
  List<Expense> _items(List<Expense> all) {
    if (!_rangeReady) return const [];
    final (from, to) = _range;
    return ExpenseFilter(from: from, to: to, sort: ExpenseSort.dateAsc)
        .apply(all);
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _custom,
    );
    if (picked != null) {
      setState(() {
        _custom = picked;
        _type = _PeriodType.custom;
      });
    }
  }

  Future<void> _export(List<Expense> items, {required bool pdf}) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      final name = 'dompetku_$_fileTag';
      final File file;
      if (pdf) {
        final bytes = await PdfExportService.build(
            expenses: items, periodLabel: _label);
        file = File(p.join(dir.path, '$name.pdf'));
        await file.writeAsBytes(bytes);
      } else {
        file = File(p.join(dir.path, '$name.csv'));
        await file.writeAsString(CsvExportService.build(items));
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile(file.path, mimeType: pdf ? 'application/pdf' : 'text/csv'),
        ],
        subject: 'Laporan pengeluaran DompetKu - $_label',
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<ExpenseProvider>().expenses;
    final items = _items(all);
    final total = StatisticsCalculator.total(items);
    final canExport = items.isNotEmpty && !_busy;
    final outline = Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(title: const Text('Ekspor Laporan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Periode', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Bulan ini'),
                  selected: _type == _PeriodType.thisMonth,
                  onSelected: (_) =>
                      setState(() => _type = _PeriodType.thisMonth),
                ),
                ChoiceChip(
                  label: const Text('Bulan lalu'),
                  selected: _type == _PeriodType.lastMonth,
                  onSelected: (_) =>
                      setState(() => _type = _PeriodType.lastMonth),
                ),
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _type == _PeriodType.all,
                  onSelected: (_) => setState(() => _type = _PeriodType.all),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: const Text('Pilih rentang'),
                  selected: _type == _PeriodType.custom,
                  onSelected: (_) => _pickCustom(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${items.length} transaksi'),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(total),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            if (_rangeReady && items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Tidak ada transaksi pada periode ini, jadi belum ada yang bisa diekspor.',
                  style: TextStyle(color: outline),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canExport ? () => _export(items, pdf: true) : null,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ekspor PDF'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: canExport ? () => _export(items, pdf: false) : null,
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Ekspor CSV'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 20),
            Text(
              'Setelah file dibuat, pilih tujuan di menu berbagi, misalnya '
              'Simpan ke File, Google Drive, atau WhatsApp.',
              style: TextStyle(color: outline),
            ),
          ],
        ),
      ),
    );
  }
}