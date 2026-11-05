import 'package:flutter/foundation.dart';

import '../database/expense_repository.dart';
import '../models/expense.dart';

/// Menyimpan daftar transaksi di memori dan memberi tahu layar saat berubah.
class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseRepository? repository})
      : _repo = repository ?? ExpenseRepository();

  final ExpenseRepository _repo;

  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Total bulan ini, dihitung dari data yang sama dengan daftar.
  int totalForMonth(DateTime month) {
    return _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  List<Expense> get recent => _expenses.take(5).toList();  
   
  /// Mencari transaksi berdasarkan id. Null jika sudah tidak ada (misal dihapus).
  Expense? byId(int id) {
    for (final e in _expenses) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await _repo.getAll();
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mengembalikan true jika berhasil.
  Future<bool> add(Expense expense) => _run(() => _repo.insert(expense));

  Future<bool> update(Expense expense) => _run(() => _repo.update(expense));

  Future<bool> remove(int id) => _run(() => _repo.delete(id));

  /// Menjalankan operasi tulis, lalu memuat ulang data agar tampilan sinkron.
  Future<bool> _run(Future<Object?> Function() action) async {
    try {
      await action();
      _expenses = await _repo.getAll();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan data: $e';
      notifyListeners();
      return false;
    }
  }
}