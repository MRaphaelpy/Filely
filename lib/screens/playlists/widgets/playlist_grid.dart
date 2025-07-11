import 'package:flutter/material.dart';

import '../../../providers/playlist_provider.dart';
import '../../../core/constants/constants.dart';
import 'playlist_grid_item.dart';

class PlaylistGrid extends StatelessWidget {
  final PlaylistProvider provider;

  const PlaylistGrid({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.defaultPadding,
          mainAxisSpacing: AppConstants.defaultPadding,
          childAspectRatio: 0.8,
        ),
        itemCount: provider.playlists.length,
        itemBuilder: (context, index) {
          final playlist = provider.playlists[index];
          return PlaylistGridItem(playlist: playlist);
        },
      ),
    );
  }
}
