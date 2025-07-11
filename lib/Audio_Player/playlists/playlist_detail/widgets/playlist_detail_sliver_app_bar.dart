import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';

class PlaylistDetailSliverAppBar extends StatelessWidget {
  final Playlist playlist;
  final Color? appBarColor;
  final bool showTitle;
  final VoidCallback onEdit;
  final VoidCallback onShowOptions;
  final VoidCallback onShuffle;

  const PlaylistDetailSliverAppBar({
    super.key,
    required this.playlist,
    required this.appBarColor,
    required this.showTitle,
    required this.onEdit,
    required this.onShowOptions,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: appBarColor,
      elevation: appBarColor == Colors.transparent ? 0 : 4,
      title: AnimatedOpacity(
        opacity: showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(playlist.name),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackground(theme),
        expandedTitleScale: 1.0,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shuffle, color: Colors.white),
          tooltip: 'Reprodução aleatória',
          onPressed: playlist.items.isEmpty ? null : onShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          tooltip: 'Editar playlist',
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: onShowOptions,
        ),
      ],
    );
  }

  Widget _buildAppBarBackground(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (playlist.coverArt != null)
          Image.network(
            playlist.coverArt!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultCoverBackground(theme);
            },
          )
        else
          _buildDefaultCoverBackground(theme),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: playlist.coverArt != null
                      ? Image.network(
                          playlist.coverArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultCover(theme);
                          },
                        )
                      : _buildDefaultCover(theme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCoverBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.tertiary.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.queue_music_rounded, size: 70, color: Colors.white),
      ),
    );
  }
}
