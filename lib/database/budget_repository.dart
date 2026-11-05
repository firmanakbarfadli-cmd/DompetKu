import 'package:sqflite/sqflite.dart';

import '../models/monthly_budget.dart';
import 'app_database.dart';

class BudgetRepository {
  Future<Database> get _db => AppDatabase.instance.database;

  /// Semua budget (jumlah barisnya kecil: maksimal 1 per bulan).
  Future<List<MonthlyBudget>> getAll() async {
    final db = await _db;
    final rows = await db.query('monthly_budgets');
    return rows.map(MonthlyBudget.fromMap).toList();
  }

  /// Simpan budget. Jika bulan itu sudah punya budget, diganti.
  Future<void> upsert(MonthlyBudget budget) async {
    final db = await _db;
    await db.insert(
      'monthly_budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}