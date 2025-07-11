import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final IconData icon;
  final String tooltip;
  final double elevation;

  const CustomFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.color,
    required this.icon,
    this.tooltip = '',
    this.elevation = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      elevation: elevation,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
