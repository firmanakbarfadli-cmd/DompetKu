import 'package:flutter/material.dart';

/// Palet warna per mode. Semua warna tema diatur di sini.
class _Palette {
  const _Palette({
    required this.brightness,
    required this.bg,
    required this.card,
    required this.field,
    required this.border,
    required this.text,
    required this.subtext,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.error,
    required this.onError,
    required this.snack,
  });

  final Brightness brightness;
  final Color bg; // latar halaman
  final Color card; // kartu, navigasi, dialog
  final Color field; // kolom input, chip
  final Color border; // garis tepi tipis
  final Color text;
  final Color subtext;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color error;
  final Color onError;
  final Color snack;

  static const dark = _Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF0B0F0D),
    card: Color(0xFF141A17),
    field: Color(0xFF1B2420),
    border: Color(0xFF232E28),
    text: Color(0xFFF1F5F2),
    subtext: Color(0xFF93A39A),
    primary: Color(0xFF4ADE80),
    onPrimary: Color(0xFF052E16),
    primaryContainer: Color(0xFF14532D),
    onPrimaryContainer: Color(0xFFBBF7D0),
    error: Color(0xFFF87171),
    onError: Color(0xFF3B0A0A),
    snack: Color(0xFF26332C),
  );

    static const light = _Palette(
    brightness: Brightness.light,
    bg: Color(0xFFEAF3ED), // latar hijau pucat, kartu putih jadi menonjol
    card: Color(0xFFFFFFFF),
    field: Color(0xFFF1F6F3),
    border: Color(0xFFD5E3DA),
    text: Color(0xFF0B1A12),
    subtext: Color(0xFF5B6E63),
    primary: Color(0xFF15803D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD1F5DC),
    onPrimaryContainer: Color(0xFF0B3B1E),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    snack: Color(0xFF1F2A24),
  );
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Poppins';

  static ThemeData get light => _build(_Palette.light);
  static ThemeData get dark => _build(_Palette.dark);

  static ThemeData _build(_Palette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      surface: p.bg,
      onSurface: p.text,
      onSurfaceVariant: p.subtext,
      surfaceContainer: p.card,
      surfaceContainerHighest: p.field,
      outline: p.subtext,
      outlineVariant: p.border,
      error: p.error,
      onError: p.onError,
    );

    TextStyle font(double size, FontWeight weight, {Color? color}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
        );

    OutlineInputBorder inputBorder(Color c, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: width),
        );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: font(22, FontWeight.w600, color: p.text),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: p.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return font(
            11,
            selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? p.primary : p.subtext,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.primary : p.subtext);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: buttonShape,
          textStyle: font(15, FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: buttonShape,
          side: BorderSide(color: p.border),
          foregroundColor: p.text,
          textStyle: font(15, FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: font(14, FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: font(14, FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(p.primary, 1.5),
        errorBorder: inputBorder(p.error),
        focusedErrorBorder: inputBorder(p.error, 1.5),
        labelStyle: TextStyle(color: p.subtext),
        hintStyle: TextStyle(color: p.subtext),
        prefixStyle: TextStyle(color: p.text, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.field,
        selectedColor: p.primary.withValues(alpha: 0.2),
        side: BorderSide(color: p.border),
        shape: const StadiumBorder(),
        checkmarkColor: p.primary,
        labelStyle: font(13, FontWeight.w500, color: p.text),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? p.primary.withValues(alpha: 0.2)
                  : p.card),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? p.primary : p.subtext),
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
          textStyle: WidgetStatePropertyAll(font(13, FontWeight.w600)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? p.onPrimary : p.subtext),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? p.primary : p.field),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.transparent
                : p.border),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.snack,
        contentTextStyle: font(14, FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }
}