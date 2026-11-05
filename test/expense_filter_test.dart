import 'package:dompetku/models/expense.dart';
import 'package:dompetku/models/expense_category.dart';
import 'package:dompetku/utils/expense_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _e(int id, String title, int amount, DateTime date,
    {ExpenseCategory cat = ExpenseCategory.food, String? note}) {
  return Expense(
    id: id,
    title: title,
    amount: amount,
    category: cat,
    date: date,
    note: note,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final data = [
    _e(1, 'Makan siang', 25000, DateTime(2026, 10, 1)),
    _e(2, 'Ojek online', 18000, DateTime(2026, 10, 5),
        cat: ExpenseCategory.transport, note: 'ke kampus'),
    _e(3, 'Buku kuliah', 90000, DateTime(2026, 10, 10),
        cat: ExpenseCategory.education),
    _e(4, 'Makan malam', 40000, DateTime(2026, 10, 10),
        note: 'Traktir teman'),
    _e(5, 'Kopi', 20000, DateTime(2026, 9, 30)),
  ];

  test('tanpa filter: semua data, terbaru di atas', () {
    final r = const ExpenseFilter().apply(data);
    expect(r.length, 5);
    expect(r.first.id, 4); // tanggal sama dengan id 3, id lebih besar dulu
    expect(r.last.id, 5);
  });

  test('cari di nama, tanpa membedakan huruf besar/kecil', () {
    final r = const ExpenseFilter(query: 'MAKAN').apply(data);
    expect(r.map((e) => e.id), [4, 1]);
  });

  test('cari juga di catatan', () {
    final r = const ExpenseFilter(query: 'kampus').apply(data);
    expect(r.map((e) => e.id), [2]);
  });

  test('filter kategori (boleh lebih dari satu)', () {
    final r = const ExpenseFilter(categories: {
      ExpenseCategory.transport,
      ExpenseCategory.education,
    }).apply(data);
    expect(r.map((e) => e.id), [3, 2]);
  });

  test('rentang tanggal inklusif di kedua ujung', () {
    final r = ExpenseFilter(
      from: DateTime(2026, 10, 5),
      to: DateTime(2026, 10, 10),
    ).apply(data);
    expect(r.map((e) => e.id).toSet(), {2, 3, 4});
  });

  test('cari + kategori + tanggal digabung', () {
    final r = ExpenseFilter(
      query: 'makan',
      categories: const {ExpenseCategory.food},
      from: DateTime(2026, 10, 2),
    ).apply(data);
    expect(r.map((e) => e.id), [4]);
  });

  test('urut nominal terbesar dan terkecil', () {
    final desc =
        const ExpenseFilter(sort: ExpenseSort.amountDesc).apply(data);
    expect(desc.first.amount, 90000);
    final asc = const ExpenseFilter(sort: ExpenseSort.amountAsc).apply(data);
    expect(asc.first.amount, 18000);
  });

  test('urut terlama', () {
    final r = const ExpenseFilter(sort: ExpenseSort.dateAsc).apply(data);
    expect(r.first.id, 5);
  });

  test('tidak ada yang cocok -> daftar kosong', () {
    final r = const ExpenseFilter(query: 'tidak ada').apply(data);
    expect(r, isEmpty);
  });

  test('isActive dan hasFilters', () {
    expect(const ExpenseFilter().isActive, false);
    expect(const ExpenseFilter(query: 'a').isActive, true);
    expect(const ExpenseFilter(query: 'a').hasFilters, false);
    expect(
        const ExpenseFilter(categories: {ExpenseCategory.food}).hasFilters,
        true);
  });
}