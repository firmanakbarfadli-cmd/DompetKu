class MonthlyBudget {
  final String yearMonth; // contoh: "2026-10"
  final int amount; // nominal budget, Rupiah utuh
  final bool isActive; // false = budget dinonaktifkan untuk bulan ini
  final DateTime updatedAt;

  const MonthlyBudget({
    required this.yearMonth,
    required this.amount,
    required this.isActive,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'year_month': yearMonth,
      'amount': amount,
      'is_active': isActive ? 1 : 0, // SQLite tidak punya tipe boolean
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MonthlyBudget.fromMap(Map<String, Object?> map) {
    return MonthlyBudget(
      yearMonth: map['year_month'] as String,
      amount: map['amount'] as int,
      isActive: (map['is_active'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  MonthlyBudget copyWith({int? amount, bool? isActive, DateTime? updatedAt}) {
    return MonthlyBudget(
      yearMonth: yearMonth,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}