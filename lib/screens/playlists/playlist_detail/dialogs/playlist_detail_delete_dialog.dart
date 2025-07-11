import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';

class PlaylistDetailDeleteDialog extends StatelessWidget {
  final Playlist playlist;
  final PlaylistProvider provider;

  const PlaylistDetailDeleteDialog({
    super.key,
    required this.playlist,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Excluir Playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Tem certeza que deseja excluir a playlist "${playlist.name}"?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Esta ação não pode ser desfeita.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () {
            provider.deletePlaylist(playlist.id);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
