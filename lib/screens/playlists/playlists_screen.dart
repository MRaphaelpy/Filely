import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/playlist_models.dart';
import '../../providers/playlist_provider.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_screen.dart';
import 'playlists_overview/widgets/playlists_empty_state.dart';
import 'playlists_overview/widgets/playlists_grid.dart';
import 'playlists_overview/widgets/playlists_options_sheet.dart';
import 'playlists_overview/dialogs/playlists_rename_dialog.dart';
import 'playlists_overview/dialogs/playlists_delete_dialog.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreatePlaylist(context),
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          if (playlistProvider.playlists.isEmpty) {
            return PlaylistsEmptyState(
              onCreatePlaylist: () => _navigateToCreatePlaylist(context),
            );
          }

          return PlaylistsGrid(
            provider: playlistProvider,
            onPlaylistTap: (playlist) =>
                _navigateToPlaylistDetail(context, playlist),
            onPlayPlaylist: (playlist) =>
                _playPlaylist(context, playlist, playlistProvider),
            onShowOptions: (playlist) =>
                _showPlaylistOptions(context, playlist, playlistProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreatePlaylist(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreatePlaylist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );
  }

  void _navigateToPlaylistDetail(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _playPlaylist(
    BuildContext context,
    Playlist playlist,
    PlaylistProvider provider,
  ) {
    if (playlist.items.isNotEmpty) {
      provider.playPlaylist(playlist);


      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.play_circle_filled, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reproduzindo "${playlist.name}"',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
          action: SnackBarAction(
            label: 'VER',
            onPressed: () => _navigateToPlaylistDetail(context, playlist),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta playlist está vazia'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPlaylistOptions(
    BuildContext context,
    Playlist playlist,
    PlaylistProvider provider,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PlaylistsOptionsSheet(
          playlist: playlist,
          provider: provider,
          onRename: () => _showRenameDialog(context, playlist, provider),
          onDelete: () => _showDeleteDialog(context, playlist, provider),
          onPlay: () => _playPlaylist(context, playlist, provider),
        );
      },
    );
  }

  void _showRenameDialog(
    BuildContext context,
    Playlist playlist,
    PlaylistProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          PlaylistsRenameDialog(playlist: playlist, provider: provider),
    ).then((result) {
      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist renomeada com sucesso'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showDeleteDialog(
    BuildContext context,
    Playlist playlist,
    PlaylistProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          PlaylistsDeleteDialog(playlist: playlist, provider: provider),
    ).then((result) {
      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "${playlist.name}" excluída'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'DESFAZER',
              onPressed: () {


                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recurso não disponível'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    });
  }
}
