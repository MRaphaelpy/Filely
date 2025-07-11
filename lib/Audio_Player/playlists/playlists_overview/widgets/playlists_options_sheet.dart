// playlists_options_sheet.dart
import 'package:flutter/material.dart';

import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';

class PlaylistsOptionsSheet extends StatelessWidget {
  final Playlist playlist;
  final PlaylistProvider? provider;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onPlay;

  const PlaylistsOptionsSheet({
    Key? key,
    required this.playlist,
    this.provider,
    this.onRename,
    this.onDelete,
    this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  playlist.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (playlist.description != null &&
                    playlist.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    playlist.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Renomear'),
            onTap: () {
              Navigator.pop(context);
              onRename?.call();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
            title: Text(
              'Excluir',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),
          if (playlist.items.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Reproduzir'),
              onTap: () {
                Navigator.pop(context);
                onPlay?.call();
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
