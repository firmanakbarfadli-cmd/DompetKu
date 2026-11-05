import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan preferensi sederhana (saat ini: tema aplikasi).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) : _themeMode = _read(_prefs);

  static const _themeKey = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static ThemeMode _read(SharedPreferences prefs) {
    switch (prefs.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners(); // tampilan berubah dulu, tanpa menunggu penyimpanan
    try {
      await _prefs.setString(_themeKey, mode.name); // system / light / dark
    } catch (_) {
      // Jika gagal menyimpan, tema tetap berubah untuk sesi ini.
    }
  }

  /// Mengembalikan preferensi ke bawaan. Tidak menyentuh transaksi/budget.
  Future<void> resetPreferences() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    try {
      await _prefs.remove(_themeKey);
    } catch (_) {}
  }
}