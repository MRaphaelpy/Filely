import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const SearchBarCustom({
    super.key,
    this.hintText = 'Buscar arquivos',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(28),
        ),
        child: TextField(
          onChanged: onChanged,
          onSubmitted: (value) {
            if (onSubmitted != null) {
              onSubmitted!();
            }
          },
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
