import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define custom color seed for Material 3
  static const Color seedColor = Color(0xFF9C27B0); // Purple
  static const Color secondarySeedColor = Color(0xFF673AB7); // Deep Purple

  // Get light theme
  static ThemeData get light => FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: seedColor,
      primaryContainer: Color(0xFFF3E5F5),
      secondary: secondarySeedColor,
      secondaryContainer: Color(0xFFEDE7F6),
      tertiary: Color(0xFF00897B),
      tertiaryContainer: Color(0xFFB2DFDB),
      appBarColor: seedColor,
      error: Color(0xFFB00020),
    ),
    useMaterial3: true,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 20,
    appBarOpacity: 0.95,
    tooltipsMatchBackground: true,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
      useTextTheme: true,
      useM2StyleDividerInM3: false,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      fabUseShape: true,
      interactionEffects: true,
      bottomNavigationBarElevation: 0,
      bottomNavigationBarOpacity: 0.95,
      navigationBarOpacity: 0.95,
      navigationRailOpacity: 0.95,

      // Rounded corners
      cardRadius: 16,
      buttonMinSize: Size(64, 40),
      inputDecoratorRadius: 12.0,
      chipRadius: 20.0,
      dialogRadius: 20.0,
      timePickerDialogRadius: 20.0,
      bottomSheetRadius: 24.0,
      //bottomSheetModalRadius: 24.0,
      appBarScrolledUnderElevation: 0.0,

      // Button styling
      elevatedButtonRadius: 20.0,
      elevatedButtonSchemeColor: SchemeColor.primary,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
      outlinedButtonRadius: 20.0,
      outlinedButtonBorderWidth: 1.5,
      outlinedButtonPressedBorderWidth: 2.0,
      textButtonRadius: 20.0,

      // Material 3 specific
      filledButtonRadius: 20.0,
      popupMenuRadius: 12.0,
      menuRadius: 12.0,
      menuBarRadius: 8.0,
      menuBarElevation: 1.0,
      snackBarRadius: 12.0,
      snackBarElevation: 4.0,
      tabBarIndicatorSchemeColor: SchemeColor.primary,
      tabBarIndicatorSize: TabBarIndicatorSize.label,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      keepPrimary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.outfit().fontFamily,
  ).copyWith(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: seedColor,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );

  // Get dark theme
  static ThemeData get dark => FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFFD0A7E4), // Lighter purple for dark theme
      primaryContainer: Color(0xFF7B1FA2),
      secondary: Color(0xFFBB86FC),
      secondaryContainer: Color(0xFF5E35B1),
      tertiary: Color(0xFF4DB6AC),
      tertiaryContainer: Color(0xFF00796B),
      appBarColor: Color(0xFF7B1FA2),
      error: Color(0xFFCF6679),
    ),
    useMaterial3: true,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.background,
    appBarOpacity: 0.95,
    surfaceTint: Colors.black,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
      useTextTheme: true,
      useM2StyleDividerInM3: false,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      fabUseShape: true,
      interactionEffects: true,
      bottomNavigationBarElevation: 0,
      bottomNavigationBarOpacity: 0.95,
      navigationBarOpacity: 0.95,
      navigationRailOpacity: 0.95,

      // Rounded corners
      cardRadius: 16,
      buttonMinSize: Size(64, 40),
      inputDecoratorRadius: 12.0,
      chipRadius: 20.0,
      dialogRadius: 20.0,
      timePickerDialogRadius: 20.0,
      bottomSheetRadius: 24.0,
      // bottomSheetModalRadius: 24.0,

      // Button styling
      elevatedButtonRadius: 20.0,
      elevatedButtonSchemeColor: SchemeColor.primary,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
      outlinedButtonRadius: 20.0,
      outlinedButtonBorderWidth: 1.5,
      outlinedButtonPressedBorderWidth: 2.0,
      textButtonRadius: 20.0,

      // Material 3 specific
      filledButtonRadius: 20.0,
      popupMenuRadius: 12.0,
      menuRadius: 12.0,
      menuBarRadius: 8.0,
      menuBarElevation: 1.0,
      snackBarRadius: 12.0,
      tabBarIndicatorSchemeColor: SchemeColor.primary,
      tabBarIndicatorSize: TabBarIndicatorSize.label,
      appBarScrolledUnderElevation: 0.0,
    ),
    keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
    tones: FlexTones.vividSurfaces(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.outfit().fontFamily,
  ).copyWith(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: const Color(0xFF7B1FA2),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );

  // Add a method to toggle theme
  static ThemeMode themeMode = ThemeMode.system;
}
