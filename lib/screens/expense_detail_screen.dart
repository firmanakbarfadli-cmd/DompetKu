import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helper.dart';
import '../widgets/empty_state.dart';
import 'expense_form_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final int expenseId;

  Future<void> _confirmDelete(BuildContext context, Expense e) async {
    // Ambil semua yang dibutuhkan SEBELUM await.
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text(
          '"${e.title}" (${CurrencyFormatter.format(e.amount)}) '
          'akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await provider.remove(e.id!);
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal menghapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = context.watch<ExpenseProvider>().byId(expenseId);

    // Terjadi sesaat setelah dihapus, sebelum layar ditutup.
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          message: 'Transaksi tidak ditemukan.',
        ),
      );
    }

    final cat = e.category;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseFormScreen(expense: e),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, e),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cat.color.withValues(alpha: 0.15),
                    child: Icon(cat.icon, color: cat.color, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.format(e.amount),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(cat.label),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Nama', value: e.title),
          _InfoRow(label: 'Tanggal', value: DateHelper.formatDisplay(e.date)),
          _InfoRow(
            label: 'Catatan',
            value: (e.note == null || e.note!.isEmpty) ? '-' : e.note!,
          ),
          _InfoRow(
              label: 'Dibuat', value: DateHelper.formatDateTime(e.createdAt)),
          _InfoRow(
              label: 'Diperbarui',
              value: DateHelper.formatDateTime(e.updatedAt)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}