import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../create_playlist_screen.dart';

class PlaylistEmptyState extends StatelessWidget {
  const PlaylistEmptyState({super.key});

  void _navigateToCreatePlaylist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 120,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Nenhuma playlist encontrada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Crie sua primeira playlist para organizar\nsuas músicas favoritas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreatePlaylist(context),
            icon: const Icon(Icons.add),
            label: const Text('Criar Playlist'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largePadding,
                vertical: AppConstants.defaultPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
