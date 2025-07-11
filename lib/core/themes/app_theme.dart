import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => FlexThemeData.light(
    surface: AppColors.lightBackground,
    scheme: FlexScheme.material,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: 'Roboto',
  );

  static ThemeData get darkTheme => FlexThemeData.dark(
    surface: AppColors.darkBackground,
    scheme: FlexScheme.material,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: 'Roboto',
  );

  static ThemeData getCurrentTheme(BuildContext context) {
    return Theme.of(context);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.darkPrimary : AppColors.lightPrimary;
  }

  static Color getAccentColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.darkAccent : AppColors.lightAccent;
  }
}
