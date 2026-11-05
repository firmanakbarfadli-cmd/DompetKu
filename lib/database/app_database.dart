import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Mengelola koneksi SQLite. Hanya ada satu instance (singleton).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'dompetku.db';
  static const int _dbVersion = 1;

  // Menyimpan Future (bukan Database) supaya jika dua bagian aplikasi
  // meminta database bersamaan, database tidak dibuka dua kali.
  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  /// Dipanggil sekali saja, saat file database baru dibuat.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');

    await db.execute('''
      CREATE TABLE monthly_budgets (
        year_month TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}