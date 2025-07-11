import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';

class PlaylistDetailControlButtons extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  const PlaylistDetailControlButtons({
    super.key,
    required this.playlist,
    required this.onPlay,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: playlist.items.isEmpty ? null : onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Reproduzir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: playlist.items.isEmpty ? null : onShuffle,
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Aleatório'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
