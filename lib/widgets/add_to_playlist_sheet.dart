import 'package:filely/screens/playlists/playlists_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../models/playlist_models.dart';
import '../screens/playlists/create_playlist_screen.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final String title;
  final String artist;
  final String filePath;
  final String? albumArt;
  final Duration? duration;

  const AddToPlaylistSheet({
    super.key,
    required this.title,
    required this.artist,
    required this.filePath,
    this.albumArt,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adicionar à playlist',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: Icon(Icons.add, color: theme.colorScheme.primary),
            ),
            title: const Text('Criar nova playlist'),
            subtitle: const Text('Criar uma nova playlist com esta música'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const CreatePlaylistScreen(),
                    ),
                  )
                  .then((_) {
                    _addToNewPlaylist(context);
                  });
            },
          ),

          const Divider(),

          Flexible(
            child: Consumer<PlaylistProvider>(
              builder: (context, provider, child) {
                if (provider.playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.playlist_add_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma playlist criada',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie sua primeira playlist para organizar suas músicas',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = provider.playlists[index];
                    final isAlreadyInPlaylist = playlist.items.any(
                      (item) => item.filePath == filePath,
                    );

                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                              theme.colorScheme.primary.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: playlist.coverArt != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  playlist.coverArt!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultCover(theme);
                                  },
                                ),
                              )
                            : _buildDefaultCover(theme),
                      ),
                      title: Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${playlist.itemCount} ${playlist.itemCount == 1 ? 'música' : 'músicas'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      trailing: isAlreadyInPlaylist
                          ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                          : Icon(
                              Icons.add_circle_outline,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                      enabled: !isAlreadyInPlaylist,
                      onTap: isAlreadyInPlaylist
                          ? null
                          : () => _addToPlaylist(context, provider, playlist),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDefaultCover(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.playlist_play,
        size: 24,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _addToPlaylist(
    BuildContext context,
    PlaylistProvider provider,
    Playlist playlist,
  ) async {
    try {
      final playlistItem = PlaylistItem(
        id: '${filePath}_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        artist: artist,
        filePath: filePath,
        albumArt: albumArt,
        duration: duration,
      );

      await provider.addItemToPlaylist(playlist.id, playlistItem);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adicionado à playlist "${playlist.name}"'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver playlist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaylistsScreen()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar à playlist: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addToNewPlaylist(BuildContext context) async {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);

    if (provider.playlists.isNotEmpty) {
      final newestPlaylist = provider.playlists.last;

      final playlistItem = PlaylistItem(
        id: '${filePath}_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        artist: artist,
        filePath: filePath,
        albumArt: albumArt,
        duration: duration,
      );

      await provider.addItemToPlaylist(newestPlaylist.id, playlistItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Música adicionada à "${newestPlaylist.name}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
