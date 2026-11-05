import '../utils/date_helper.dart';
import 'expense_category.dart';

class Expense {
  final int? id; // null saat transaksi belum disimpan ke database
  final String title;
  final int amount; // Rupiah utuh, tanpa desimal
  final ExpenseCategory category;
  final DateTime date; // hanya tanggalnya yang dipakai
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Objek -> Map untuk disimpan ke SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': DateHelper.toDbDate(date),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map dari SQLite -> objek.
  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      category: ExpenseCategory.fromKey(map['category'] as String),
      date: DateHelper.fromDbDate(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Salinan dengan sebagian field diganti (dipakai saat edit).
  Expense copyWith({
    int? id,
    String? title,
    int? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}