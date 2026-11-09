import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helper.dart';

/// Form tambah (expense == null) dan edit (expense != null).
class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  bool get isEdit => expense != null;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late ExpenseCategory _category;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final now = DateTime.now();
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl = TextEditingController(text: e?.amount.toString() ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? ExpenseCategory.food;
    _date = e?.date ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = _date.isAfter(today) ? _date : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<ExpenseProvider>();
    final old = widget.expense;
    final now = DateTime.now();
    final note = _noteCtrl.text.trim();

    final expense = Expense(
      id: old?.id,
      title: _titleCtrl.text.trim(),
      amount: int.parse(_amountCtrl.text),
      category: _category,
      date: _date,
      note: note.isEmpty ? null : note,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );

    final ok = widget.isEdit
        ? await provider.update(expense)
        : await provider.add(expense);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(
            widget.isEdit ? 'Transaksi diperbarui' : 'Transaksi disimpan'),
      ));
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Gagal menyimpan transaksi'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const noBorder = InputBorder.none;

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(
            text,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.outline,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Nominal ----
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      children: [
                        Text(
                          'NOMINAL',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.outline,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextFormField(
                          controller: _amountCtrl,
                          autofocus: !widget.isEdit,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                            hintText: '0',
                            filled: false,
                            border: noBorder,
                            enabledBorder: noBorder,
                            focusedBorder: noBorder,
                            errorBorder: noBorder,
                            focusedErrorBorder: noBorder,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Nominal wajib diisi';
                            }
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) {
                              return 'Nominal harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _amountCtrl,
                          builder: (context, value, _) {
                            final n = int.tryParse(value.text);
                            return Text(
                              (n == null || n == 0)
                                  ? ' '
                                  : CurrencyFormatter.format(n),
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Kategori ----
                sectionLabel('KATEGORI'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ExpenseCategory.values.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 96,
                  ),
                  itemBuilder: (context, i) {
                    final c = ExpenseCategory.values[i];
                    final selected = c == _category;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _category = c),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: c.color
                                  .withValues(alpha: selected ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    selected ? c.color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(c.icon, color: c.color),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              c.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color:
                                    selected ? scheme.onSurface : scheme.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ---- Detail ----
                sectionLabel('DETAIL'),
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  decoration: const InputDecoration(
                    labelText: 'Nama pengeluaran',
                    hintText: 'Contoh: Makan siang',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nama pengeluaran wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Text(DateHelper.formatDisplay(_date)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEdit ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}