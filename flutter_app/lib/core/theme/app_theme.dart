import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary      = Color(0xFF7C3AED);
  static const Color primaryDark  = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color accent       = Color(0xFFEC4899);
  static const Color surface      = Color(0xFFF5F3FF);
  static const Color cardBg       = Colors.white;
  static const Color deepBg       = Color(0xFF1A0933);

  // ── Light theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        primary: primary,
        secondary: accent,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFEDE9FE), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDE9FE),
        labelStyle: const TextStyle(
          color: Color(0xFF6D28D9),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFFC4B5FD)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEDE9FE),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: primary, fontSize: 11, fontWeight: FontWeight.w700);
          }
          return const TextStyle(
              color: Color(0xFFC4B5FD), fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: Color(0xFFC4B5FD), size: 22);
        }),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1A0933), letterSpacing: -0.5),
        headlineMedium: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A0933), letterSpacing: -0.3),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A0933)),
        titleMedium: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A0933)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4C1D95)),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF8B5CF6)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEDE9FE), thickness: 1),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF13082A),
        primary: const Color(0xFF9F7AEA),
        secondary: const Color(0xFFF687B3),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0520),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF13082A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C0F3A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2D1060), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D1060),
        labelStyle: const TextStyle(
          color: Color(0xFFC4B5FD),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C0F3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D1060)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D1060)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9F7AEA), width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF553C9A)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9F7AEA),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF13082A),
        indicatorColor: const Color(0xFF2D1060),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: Color(0xFF9F7AEA), fontSize: 11, fontWeight: FontWeight.w700);
          }
          return const TextStyle(
              color: Color(0xFF553C9A), fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF9F7AEA), size: 22);
          }
          return const IconThemeData(color: Color(0xFF553C9A), size: 22);
        }),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFFF5F3FF), letterSpacing: -0.5),
        headlineMedium: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFF5F3FF), letterSpacing: -0.3),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFF5F3FF)),
        titleMedium: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFF5F3FF)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFC4B5FD)),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF7C3AED)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2D1060), thickness: 1),
    );
  }
}