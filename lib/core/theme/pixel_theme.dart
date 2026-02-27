import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pixel_colors.dart';
import 'pixel_text_styles.dart';

class PixelTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PixelColors.background,
      primaryColor: PixelColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: PixelColors.primary,
        secondary: PixelColors.accent,
        surface: PixelColors.surface,
        error: PixelColors.danger,
      ),
      textTheme: TextTheme(
        bodyMedium: PixelTextStyles.body,
        bodyLarge: PixelTextStyles.body,
        titleLarge: PixelTextStyles.header,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: PixelColors.surface,
        titleTextStyle: PixelTextStyles.appTitle,
        iconTheme: const IconThemeData(color: PixelColors.primary),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: PixelColors.primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PixelColors.surface,
        selectedItemColor: PixelColors.primary,
        unselectedItemColor: PixelColors.textMuted,
        selectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
        unselectedLabelStyle: GoogleFonts.vt323(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PixelColors.primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // 0 radius
          side: const BorderSide(color: PixelColors.primaryDark, width: 2),
        ),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PixelColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PixelColors.border, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PixelColors.border, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PixelColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PixelColors.danger, width: 2),
        ),
        hintStyle: PixelTextStyles.bodyMuted,
        labelStyle: PixelTextStyles.body,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PixelColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: PixelColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: PixelColors.border, width: 2),
        ),
      ),
    );
  }
}
