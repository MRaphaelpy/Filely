import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';

class PlaylistDetailSongTile extends StatelessWidget {
  final PlaylistItem item;
  final int index;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;
  final VoidCallback onShowOptions;

  const PlaylistDetailSongTile({
    super.key,
    required this.item,
    required this.index,
    required this.isCurrentlyPlaying,
    required this.onTap,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isCurrentlyPlaying ? 2 : 0,
      color: isCurrentlyPlaying
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentlyPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: isCurrentlyPlaying ? 1 : 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrentlyPlaying
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),

                  if (isCurrentlyPlaying)
                    Icon(
                      Icons.equalizer_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    )
                  else
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentlyPlaying
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            title: Text(
              item.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isCurrentlyPlaying
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isCurrentlyPlaying
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.artist.isNotEmpty ? item.artist : 'Desconhecido',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCurrentlyPlaying
                    ? theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      )
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.duration != null)
                  Text(
                    _formatDurationCompact(item.duration!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCurrentlyPlaying
                          ? theme.colorScheme.onPrimaryContainer.withOpacity(
                              0.8,
                            )
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  splashRadius: 24,
                  tooltip: 'Opções',
                  onPressed: onShowOptions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDurationCompact(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
