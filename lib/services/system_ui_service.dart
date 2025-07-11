// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../core/constants/app_colors.dart';

// class SystemUIService {
//   static Future<void> configureSystemUI({
//     bool isDarkMode = false,
//     bool hideStatusBar = false,
//   }) async {
//     if (hideStatusBar) {
//       await SystemChrome.setEnabledSystemUIMode(
//         SystemUiMode.manual,
//         overlays: [],
//       );
//       return;
//     }

//     await SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: SystemUiOverlay.values,
//     );

//     final iconBrightness = isDarkMode ? Brightness.light : Brightness.dark;

//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         systemNavigationBarColor: isDarkMode
//             ? AppColors.darkBackground
//             : AppColors.lightBackground,
//         statusBarIconBrightness: iconBrightness,
//         systemNavigationBarIconBrightness: iconBrightness,
//       ),
//     );
//   }

//   static Future<void> hideSystemUI() async {
//     await configureSystemUI(hideStatusBar: true);
//   }

//   static Future<void> showSystemUI({bool isDarkMode = false}) async {
//     await configureSystemUI(isDarkMode: isDarkMode);
//   }
// }
