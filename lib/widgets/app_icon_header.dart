import 'package:flutter/material.dart';

class AppIconHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final double iconSize;
  final double containerSize;

  const AppIconHeader({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    this.iconSize = 20,
    this.containerSize = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Hero(
          tag: 'app_icon',
          child: Container(
            height: containerSize,
            width: containerSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(containerSize / 4),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
