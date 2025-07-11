import 'package:flutter/material.dart';

import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';
import 'playlist_detail_song_tile.dart';

class PlaylistDetailSongsList extends StatelessWidget {
  final Playlist playlist;
  final PlaylistProvider provider;
  final Function(int, int) onReorder;
  final Function(int) onPlayFromHere;
  final Function(PlaylistItem, int) onShowSongOptions;

  const PlaylistDetailSongsList({
    super.key,
    required this.playlist,
    required this.provider,
    required this.onReorder,
    required this.onPlayFromHere,
    required this.onShowSongOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverReorderableList(
      itemCount: playlist.items.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final item = playlist.items[index];
        final isCurrentlyPlaying =
            provider.currentPlaylist?.id == playlist.id &&
            provider.currentIndex == index;

        return ReorderableDelayedDragStartListener(
          key: ValueKey(item.id),
          index: index,
          child: PlaylistDetailSongTile(
            item: item,
            index: index,
            isCurrentlyPlaying: isCurrentlyPlaying,
            onTap: () => onPlayFromHere(index),
            onShowOptions: () => onShowSongOptions(item, index),
          ),
        );
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 6,
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }
}
