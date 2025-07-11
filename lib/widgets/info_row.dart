import 'package:flutter/material.dart';
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isError;
  final bool copyable;
  final VoidCallback? onCopy;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isError = false,
    this.copyable = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Icon(
                icon,
                size: 20,
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyable && onCopy != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copiar',
                    onPressed: onCopy,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
