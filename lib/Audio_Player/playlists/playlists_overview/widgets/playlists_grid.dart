import 'package:Filely/Audio_Player/playlists/playlists_overview/widgets/playlists_grid_item.dart';
import 'package:flutter/material.dart';

import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';

class PlaylistsGrid extends StatelessWidget {
  final PlaylistProvider provider;
  final Function(Playlist) onPlaylistTap;
  final Function(Playlist) onPlayPlaylist;
  final Function(Playlist) onShowOptions;

  const PlaylistsGrid({
    super.key,
    required this.provider,
    required this.onPlaylistTap,
    required this.onPlayPlaylist,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final playlist = provider.playlists[index];
              return PlaylistsGridItem(
                playlist: playlist,
                onTap: () => onPlaylistTap(playlist),
                onPlay: () => onPlayPlaylist(playlist),
                onShowOptions: () => onShowOptions(playlist),
              );
            }, childCount: provider.playlists.length),
          ),
        ),
      ],
    );
  }
}
