import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/playlist_models.dart';
import '../../../providers/playlist_provider.dart';

class PlaylistSongRemoveDialog extends StatelessWidget {
  final PlaylistItem item;
  final String playlistId;
  final VoidCallback onSuccess;

  const PlaylistSongRemoveDialog({
    super.key,
    required this.item,
    required this.playlistId,
    required this.onSuccess,
  });

  void _removeFromPlaylist(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);
    provider.removeItemFromPlaylist(playlistId, item.id);
    Navigator.of(context).pop();
    onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Remover música'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_circle_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Tem certeza que deseja remover "${item.title}" da playlist?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'O arquivo não será excluído da sua biblioteca.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => _removeFromPlaylist(context),
          child: const Text('Remover'),
        ),
      ],
    );
  }
}
