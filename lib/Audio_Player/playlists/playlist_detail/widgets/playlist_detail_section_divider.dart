import 'package:flutter/material.dart';

class PlaylistDetailSectionDivider extends StatelessWidget {
  final String title;

  const PlaylistDetailSectionDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
