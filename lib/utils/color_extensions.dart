import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color withOpacity(double opacity) {
    return Color.fromRGBO(red, green, blue, opacity.clamp(0.0, 1.0));
  }
}

extension MaterialColorExtensions on MaterialColor {
  Color withOpacity(double opacity) {
    return Color.fromRGBO(
      shade500.red,
      shade500.green,
      shade500.blue,
      opacity.clamp(0.0, 1.0),
    );
  }
}
