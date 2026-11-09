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
    _formKey.currentState?.reset(); // hapus pesan error bulan sebelumnya
  }

  String? _validate() {
    final v = _ctrl.text;
    if (v.isEmpty) return 'Nominal budget wajib diisi';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
    return null;
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const noBorder = InputBorder.none;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bulanan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // ---- Pemilih bulan ----
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
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
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
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
            ),
            const SizedBox(height: 12),

            // ---- Ringkasan ----
            BudgetCard(month: _month),
            const SizedBox(height: 12),

            // ---- Nominal ----
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    children: [
                      Text(
                        'NOMINAL BUDGET',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.outline,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FormField<String>(
                        validator: (_) => _validate(),
                        builder: (state) => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Rp',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IntrinsicWidth(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        minWidth: 36, maxWidth: 240),
                                    child: TextField(
                                      controller: _ctrl,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(12),
                                      ],
                                      onChanged: (v) => state.didChange(v),
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: '0',
                                        isCollapsed: true,
                                        filled: false,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        border: noBorder,
                                        enabledBorder: noBorder,
                                        focusedBorder: noBorder,
                                        errorBorder: noBorder,
                                        focusedErrorBorder: noBorder,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                      color: scheme.error, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _ctrl,
                        builder: (context, value, _) {
                          final n = int.tryParse(value.text);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              (n == null || n == 0)
                                  ? ' '
                                  : CurrencyFormatter.format(n),
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _save,
                          child: Text(budget == null
                              ? 'Simpan Budget'
                              : 'Perbarui Budget'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ---- Saklar aktif ----
            Card(
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: const Text('Gunakan budget bulan ini'),
                subtitle: Text(budget == null
                    ? 'Simpan nominal dulu untuk mengaktifkan.'
                    : 'Menonaktifkan tidak menghapus transaksi.'),
                value: budget?.isActive ?? false,
                onChanged: budget == null
                    ? null
                    : (v) =>
                        context.read<BudgetProvider>().setActive(_month, v),
              ),
            ),

            // ---- Salin dari bulan lalu ----
            if (prev != null && prev.amount > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copyFromPrevious,
                  icon: const Icon(Icons.copy),
                  label: Text(
                      'Salin dari bulan lalu (${CurrencyFormatter.format(prev.amount)})'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: scheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Budget berlaku per bulan, bukan per kategori. Pengeluaran '
                    'tetap bisa dicatat meskipun budget sudah habis atau terlampaui.',
                    style: TextStyle(color: scheme.outline, fontSize: 12),
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