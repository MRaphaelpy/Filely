import 'package:flutter/material.dart';
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outline;
  final bool filled;
  final bool expanded;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.outline = false,
    this.filled = true,
    this.expanded = false,
    this.color,
    this.textColor,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final btn = outline
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
            label: Text(text),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? theme.colorScheme.primary,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              side: BorderSide(color: color ?? theme.colorScheme.primary),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
            label: Text(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: filled
                  ? (color ?? theme.colorScheme.primary)
                  : Colors.transparent,
              foregroundColor: textColor ?? theme.colorScheme.onPrimary,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              elevation: filled ? 2 : 0,
            ),
          );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
