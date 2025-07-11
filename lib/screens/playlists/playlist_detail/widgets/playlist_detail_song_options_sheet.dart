import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';
import '../../../../playerAudio/audio_player_screen.dart';
import '../../dialogs/playlist_song_remove_dialog.dart';

class PlaylistDetailSongOptionsSheet extends StatelessWidget {
  final PlaylistItem item;
  final int index;
  final Playlist playlist;
  final PlaylistProvider provider;
  final Function(int) onPlayFromHere;
  final Function(String) showSnackMessage;

  const PlaylistDetailSongOptionsSheet({
    super.key,
    required this.item,
    required this.index,
    required this.playlist,
    required this.provider,
    required this.onPlayFromHere,
    required this.showSnackMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        ListTile(
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            item.artist.isNotEmpty ? item.artist : 'Desconhecido',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.albumArt != null
                ? Image.network(
                    item.albumArt!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultCover(theme);
                    },
                  )
                : _buildDefaultCover(theme),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.play_arrow_rounded),
          title: const Text('Reproduzir esta música'),
          onTap: () {
            Navigator.pop(context);
            onPlayFromHere(index);
          },
        ),
        ListTile(
          leading: const Icon(Icons.play_arrow_rounded),
          title: const Text('Reproduzir a partir daqui'),
          onTap: () {
            Navigator.pop(context);
            onPlayFromHere(index);
          },
        ),
        ListTile(
          leading: const Icon(Icons.open_in_new_rounded),
          title: const Text('Abrir no player'),
          onTap: () {
            Navigator.pop(context);
            _openPlayer(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.remove_circle_outline_rounded,
            color: theme.colorScheme.error,
          ),
          title: Text(
            'Remover da playlist',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () {
            Navigator.pop(context);
            _showRemoveDialog(context);
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDefaultCover(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      color: theme.colorScheme.primaryContainer,
      child: Icon(Icons.music_note, color: theme.colorScheme.primary),
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(
          title: item.title,
          artist: item.artist,
          albumArtUrl: item.albumArt ?? '',
          audioUrl: item.filePath,
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlaylistSongRemoveDialog(
        item: item,
        playlistId: playlist.id,
        onSuccess: () {
          showSnackMessage('"${item.title}" removida da playlist');
        },
      ),
    );
  }
}
