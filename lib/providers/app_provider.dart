import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/themes/themes.dart';
import '../core/constants/app_colors.dart';

class AppProvider extends ChangeNotifier {
  Key key = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late ThemeData theme;

  static const String _themePreferenceKey = 'theme';
  static const String _lightThemeValue = 'light';
  static const String _darkThemeValue = 'dark';

  AppProvider() {
    theme = AppTheme.lightTheme;
    checkTheme();
  }

  void setKey(Key value) {
    key = value;
    notifyListeners();
  }

  void setNavigatorKey(GlobalKey<NavigatorState> value) {
    navigatorKey = value;
    notifyListeners();
  }

  Future<void> setTheme(ThemeData themeData, String themeMode) async {
    theme = themeData;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, themeMode);

      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      final statusBarColor = themeMode == _darkThemeValue
          ? AppColors.backgroundSmokeWhiteOpacity
          : AppColors.backgroundSmokeWhiteOpacity;

      final iconBrightness = themeMode == _darkThemeValue
          ? Brightness.light
          : Brightness.dark;

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: iconBrightness,
          systemNavigationBarColor: statusBarColor,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar tema: $e');
    }

    notifyListeners();
  }

  ThemeData getTheme() {
    return theme;
  }

  Future<ThemeData> checkTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme =
          prefs.getString(_themePreferenceKey) ?? _lightThemeValue;

      if (savedTheme == _lightThemeValue) {
        await setTheme(AppTheme.lightTheme, _lightThemeValue);
        return AppTheme.lightTheme;
      } else {
        await setTheme(AppTheme.darkTheme, _darkThemeValue);
        return AppTheme.darkTheme;
      }
    } catch (e) {
      debugPrint('Erro ao carregar tema: $e');

      await setTheme(AppTheme.lightTheme, _lightThemeValue);
      return AppTheme.lightTheme;
    }
  }

  Future<void> toggleTheme() async {
    if (theme == AppTheme.lightTheme) {
      await setTheme(AppTheme.darkTheme, _darkThemeValue);
    } else {
      await setTheme(AppTheme.lightTheme, _lightThemeValue);
    }
  }

  bool get isDarkTheme => theme == AppTheme.darkTheme;
}
