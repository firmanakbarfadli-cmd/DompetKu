import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/currency_formatter.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cat = expense.category;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: cat.color.withValues(alpha: 0.15),
        child: Icon(cat.icon, color: cat.color),
      ),
      title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(cat.label),
      trailing: Text(
        CurrencyFormatter.format(expense.amount),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}