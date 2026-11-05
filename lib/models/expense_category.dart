import 'package:flutter/material.dart';

/// Kategori pengeluaran. Di database disimpan sebagai [name] (misal "food").
enum ExpenseCategory {
  food('Makanan', Icons.restaurant, Color(0xFFF59E0B)),
  transport('Transportasi', Icons.directions_bus, Color(0xFF3B82F6)),
  shopping('Belanja', Icons.shopping_bag, Color(0xFFEC4899)),
  bills('Tagihan', Icons.receipt_long, Color(0xFF8B5CF6)),
  health('Kesehatan', Icons.favorite, Color(0xFFEF4444)),
  entertainment('Hiburan', Icons.movie, Color(0xFF14B8A6)),
  education('Pendidikan', Icons.school, Color(0xFF6366F1)),
  other('Lainnya', Icons.category, Color(0xFF6B7280));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Mengubah teks dari database kembali ke enum.
  /// Jika tidak dikenali, dianggap "Lainnya" agar aplikasi tidak crash.
  static ExpenseCategory fromKey(String key) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => ExpenseCategory.other,
    );
  }
}