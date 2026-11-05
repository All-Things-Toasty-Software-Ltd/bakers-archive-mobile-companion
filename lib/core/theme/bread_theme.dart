import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bread_colors.dart';

class BreadTheme {
  BreadTheme._();

  static ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    scaffoldBg: BreadColors.crumbCream,
    cardBg: BreadColors.crumbWhite,
    primaryColor: BreadColors.crustGoldDark,
    accentColor: BreadColors.crustGold,
    textColor: BreadColors.textDarkPrimary,
    subtextColor: BreadColors.textDarkSecondary,
    borderColor: BreadColors.crumbBorder,
  );

  static ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    scaffoldBg: BreadColors.ovenBlack,
    cardBg: BreadColors.ovenCharcoal,
    primaryColor: BreadColors.crustGold,
    accentColor: BreadColors.butterYellow,
    textColor: BreadColors.textLightPrimary,
    subtextColor: BreadColors.textLightSecondary,
    borderColor: BreadColors.toastBorder,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color cardBg,
    required Color primaryColor,
    required Color accentColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final baseTextTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final displayFont = GoogleFonts.playfairDisplayTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: isDark ? BreadColors.crustDeep : BreadColors.crumbWarmGrey,
        onPrimaryContainer: isDark ? BreadColors.crumbWhite : BreadColors.crustDeep,
        secondary: accentColor,
        onSecondary: Colors.white,
        surface: cardBg,
        onSurface: textColor,
        surfaceContainerHighest: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
        outline: borderColor,
        error: BreadColors.ovenRed,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: displayFont.displayLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: displayFont.displayMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: displayFont.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textColor,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: subtextColor,
          height: 1.45,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: displayFont.titleLarge?.copyWith(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
        ),
        prefixIconColor: primaryColor,
        suffixIconColor: subtextColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
        disabledColor: Colors.transparent,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        labelStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        side: BorderSide(color: borderColor, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
