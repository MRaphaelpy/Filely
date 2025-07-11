import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/playlist_models.dart';
import '../../../providers/playlist_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../l10n/app_localizations.dart';

class PlaylistDeleteDialog extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDeleteDialog({super.key, required this.playlist});

  void _deletePlaylist(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);
    provider.deletePlaylist(playlist.id);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "${playlist.name}" excluída'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.undo(context),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.featureNotAvailable),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deletePlaylist),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            '${l10n.deleteConfirmMessage} "${playlist.name}"?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            l10n.actionCannotBeUndone,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
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
          child: Text(
            l10n.cancel,
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => _deletePlaylist(context),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
