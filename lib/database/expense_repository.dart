import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';
import '../utils/date_helper.dart';
import 'app_database.dart';

/// Semua akses data transaksi lewat sini.
class ExpenseRepository {
  Future<Database> get _db => AppDatabase.instance.database;

  /// Menambah transaksi. Mengembalikan ID baru dari database.
  Future<int> insert(Expense expense) async {
    final db = await _db;
    return db.insert('expenses', expense.toMap());
  }

  /// Mengubah transaksi yang sudah ada (dicari lewat id).
  Future<int> update(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Transaksi tanpa id tidak bisa diubah.');
    }
    final db = await _db;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<Expense?> getById(int id) async {
    final db = await _db;
    final rows = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  /// Semua transaksi, terbaru di atas.
  Future<List<Expense>> getAll() async {
    final db = await _db;
    final rows = await db.query('expenses', orderBy: 'date DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  /// Beberapa transaksi terbaru (untuk dashboard).
  Future<List<Expense>> getRecent({int limit = 5}) async {
    final db = await _db;
    final rows = await db.query(
      'expenses',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Total pengeluaran pada bulan dari [month], berdasarkan tanggal transaksi.
  Future<int> totalForMonth(DateTime month) async {
    final db = await _db;
    final start = DateHelper.toDbDate(DateHelper.monthStart(month));
    final end = DateHelper.toDbDate(DateHelper.nextMonthStart(month));
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM expenses WHERE date >= ? AND date < ?',
      [start, end],
    );
    return (rows.first['total'] as num).toInt();
  }
}