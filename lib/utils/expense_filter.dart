import '../models/expense.dart';
import '../models/expense_category.dart';

enum ExpenseSort { dateDesc, dateAsc, amountDesc, amountAsc }

extension ExpenseSortLabel on ExpenseSort {
  String get label {
    switch (this) {
      case ExpenseSort.dateDesc:
        return 'Terbaru';
      case ExpenseSort.dateAsc:
        return 'Terlama';
      case ExpenseSort.amountDesc:
        return 'Nominal terbesar';
      case ExpenseSort.amountAsc:
        return 'Nominal terkecil';
    }
  }

  bool get byDate => this == ExpenseSort.dateDesc || this == ExpenseSort.dateAsc;
}

/// Kondisi pencarian + filter + urutan. Semua digabung (AND).
class ExpenseFilter {
  const ExpenseFilter({
    this.query = '',
    this.categories = const {},
    this.from,
    this.to,
    this.sort = ExpenseSort.dateDesc,
  });

  final String query;
  final Set<ExpenseCategory> categories; // kosong = semua kategori
  final DateTime? from; // inklusif
  final DateTime? to; // inklusif
  final ExpenseSort sort;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Filter selain kata kunci (untuk lencana di tombol filter).
  bool get hasFilters =>
      categories.isNotEmpty ||
      from != null ||
      to != null ||
      sort != ExpenseSort.dateDesc;

  bool get isActive => hasQuery || hasFilters;

  ExpenseFilter copyWith({String? query}) => ExpenseFilter(
        query: query ?? this.query,
        categories: categories,
        from: from,
        to: to,
        sort: sort,
      );

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Expense> apply(List<Expense> all) {
    final q = query.trim().toLowerCase();
    final fromDay = from == null ? null : _day(from!);
    final toDay = to == null ? null : _day(to!);

    final result = all.where((e) {
      if (q.isNotEmpty) {
        final inTitle = e.title.toLowerCase().contains(q);
        final inNote = (e.note ?? '').toLowerCase().contains(q);
        if (!inTitle && !inNote) return false;
      }
      if (categories.isNotEmpty && !categories.contains(e.category)) {
        return false;
      }
      final d = _day(e.date);
      if (fromDay != null && d.isBefore(fromDay)) return false;
      if (toDay != null && d.isAfter(toDay)) return false;
      return true;
    }).toList();

    int byDateDesc(Expense a, Expense b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : (b.id ?? 0).compareTo(a.id ?? 0);
    }

    switch (sort) {
      case ExpenseSort.dateDesc:
        result.sort(byDateDesc);
      case ExpenseSort.dateAsc:
        result.sort((a, b) => byDateDesc(b, a));
      case ExpenseSort.amountDesc:
        result.sort((a, b) {
          final c = b.amount.compareTo(a.amount);
          return c != 0 ? c : byDateDesc(a, b);
        });
      case ExpenseSort.amountAsc:
        result.sort((a, b) {
          final c = a.amount.compareTo(b.amount);
          return c != 0 ? c : byDateDesc(a, b);
        });
    }
    return result;
  }
}