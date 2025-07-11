import 'package:flutter/material.dart';
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding,
    this.borderRadius = 16,
    this.color,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                color ??
                (isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(borderRadius),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
