import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/budget_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _syncField();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Mengisi kolom nominal sesuai budget bulan yang sedang dipilih.
  void _syncField() {
    final b = context.read<BudgetProvider>().budgetFor(_month);
    _ctrl.text = b == null ? '' : b.amount.toString();
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _syncField();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final provider = context.read<BudgetProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await provider.setBudget(_month, int.parse(_ctrl.text));
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Budget disimpan'
          : (provider.error ?? 'Gagal menyimpan budget')),
    ));
  }

  Future<void> _copyFromPrevious() async {
    final provider = context.read<BudgetProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await provider.copyFromPreviousMonth(_month);
    if (!mounted) return;
    _syncField();
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Budget disalin dari bulan lalu'
          : 'Tidak ada budget bulan lalu untuk disalin'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BudgetProvider>();
    final budget = provider.budgetFor(_month);
    final prev = provider.previousOf(_month);
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(_month);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bulanan')),
      body: SafeArea(
        child: ListView(
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
                    child: Text(
                      monthLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Bulan berikutnya',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BudgetCard(month: _month),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Nominal budget $monthLabel',
                      prefixText: 'Rp ',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Nominal budget wajib diisi';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) {
                        return 'Nominal harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _save,
                    child: Text(budget == null
                        ? 'Simpan Budget'
                        : 'Perbarui Budget'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Gunakan budget bulan ini'),
              subtitle: Text(budget == null
                  ? 'Simpan nominal dulu untuk mengaktifkan.'
                  : 'Menonaktifkan tidak menghapus transaksi.'),
              value: budget?.isActive ?? false,
              onChanged: budget == null
                  ? null
                  : (v) => context
                      .read<BudgetProvider>()
                      .setActive(_month, v),
            ),
            if (prev != null && prev.amount > 0) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _copyFromPrevious,
                icon: const Icon(Icons.copy),
                label: Text(
                    'Salin dari bulan lalu (${CurrencyFormatter.format(prev.amount)})'),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Budget berlaku per bulan, bukan per kategori. Pengeluaran '
              'tetap bisa dicatat meskipun budget sudah habis atau terlampaui.',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}