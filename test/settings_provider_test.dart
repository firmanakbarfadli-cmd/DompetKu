import 'package:dompetku/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('bawaan: ikuti sistem', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(SettingsProvider(prefs).themeMode, ThemeMode.system);
  });

  test('pilihan tema tersimpan dan terbaca lagi (simulasi buka ulang)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SettingsProvider(prefs).setThemeMode(ThemeMode.dark);

    // Provider baru dengan prefs yang sama = aplikasi dibuka kembali.
    expect(SettingsProvider(prefs).themeMode, ThemeMode.dark);
  });

  test('nilai tersimpan yang tidak dikenal dianggap sistem', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'aneh'});
    final prefs = await SharedPreferences.getInstance();
    expect(SettingsProvider(prefs).themeMode, ThemeMode.system);
  });

  test('reset mengembalikan ke sistem', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsProvider(prefs);
    expect(s.themeMode, ThemeMode.light);
    await s.resetPreferences();
    expect(s.themeMode, ThemeMode.system);
    expect(SettingsProvider(prefs).themeMode, ThemeMode.system);
  });
}