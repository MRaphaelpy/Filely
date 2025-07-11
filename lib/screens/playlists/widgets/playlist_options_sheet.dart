import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/playlist_models.dart';
import '../dialogs/playlist_delete_dialog.dart';
import '../dialogs/playlist_rename_dialog.dart';

class PlaylistOptionsSheet extends StatelessWidget {
  final Playlist playlist;

  const PlaylistOptionsSheet({super.key, required this.playlist});

  void _showRenameDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => PlaylistRenameDialog(playlist: playlist),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => PlaylistDeleteDialog(playlist: playlist),
    );
  }

  void _playPlaylist(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
            onTap: () => _showRenameDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
            title: Text(
              'Excluir',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showDeleteDialog(context),
          ),
          if (playlist.items.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: Text(AppLocalizations.of(context)!.playPlaylist),
              onTap: () => _playPlaylist(context),
            ),
          ],
          const SizedBox(height: AppConstants.smallPadding),
        ],
      ),
    );
  }
}
