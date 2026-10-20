import 'package:flutter/material.dart';

class ThemeColors {
  static const Color _primary = Color.fromARGB(255, 59, 140, 46);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _primary,
    canvasColor: Color(0xFF7EBC0A),
    // Sem um colorScheme próprio o Material 3 usa a paleta roxa padrão,
    // que tinge fundos, AppBars, cards e diálogos.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: Color(0xFFF2F2F2),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Colors.white,
    ),
  );
}
