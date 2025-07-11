// playlist_detail_options_sheet.dart
import 'package:flutter/material.dart';

import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';
import '../../dialogs/playlist_detail_delete_dialog.dart';
import '../../dialogs/playlist_detail_edit_dialog.dart';

class PlaylistDetailOptionsSheet extends StatelessWidget {
  final Playlist playlist;
  final PlaylistProvider? provider;
  final Function(String)? showSnackMessage;

  const PlaylistDetailOptionsSheet({
    Key? key,
    required this.playlist,
    this.provider,
    this.showSnackMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Editar playlist'),
            onTap: () {
              Navigator.pop(context);
              _showEditDialog(context);
            },
          ),
          if (playlist.items.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Reproduzir tudo'),
              onTap: () {
                Navigator.pop(context);
                provider?.setShuffle(false);
                provider?.playPlaylist(playlist);
                showSnackMessage?.call('Reproduzindo "${playlist.name}"');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle_rounded),
              title: const Text('Reprodução aleatória'),
              onTap: () {
                Navigator.pop(context);
                provider?.setShuffle(true);
                provider?.playPlaylist(playlist);
                showSnackMessage?.call('Reprodução aleatória ativada');
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
            title: Text(
              'Excluir playlist',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlaylistDetailEditDialog(
        playlist: playlist,
        provider: provider ?? PlaylistProvider(),
      ),
    ).then((result) {
      if (result == true) {
        showSnackMessage?.call('Playlist atualizada com sucesso');
      }
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlaylistDetailDeleteDialog(
        playlist: playlist,
        provider: provider ?? PlaylistProvider(),
      ),
    ).then((_) {
      showSnackMessage?.call('Playlist "${playlist.name}" excluída');
    });
  }
}
