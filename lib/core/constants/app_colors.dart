import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPrimary = Color(0xfff3f4f9);
  static const Color darkPrimary = Color(0xff1f1f1f);
  static const Color lightAccent = Color(0xff597ef7);
  static const Color darkAccent = Color(0xff597ef7);
  static const Color lightBackground = Color(0xfff3f4f9);
  static const Color darkBackground = Color(0xff121212);
  static const Color backgroundSmokeWhite = Color(0xffB0C6D0);

  static const Color purple = Colors.purple;
  static const Color blue = Colors.blue;
  static const Color red = Colors.red;
  static const Color teal = Colors.teal;
  static const Color pink = Colors.pink;
  static const Color green = Colors.green;
  static const Color orange = Colors.orange;

  static Color get backgroundSmokeWhiteOpacity =>
      backgroundSmokeWhite.withValues(alpha: 0.1);
}
