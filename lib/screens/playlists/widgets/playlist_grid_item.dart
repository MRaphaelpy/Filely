import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/playlist_models.dart';
import '../../../providers/playlist_provider.dart';
import '../playlist_detail_screen.dart';
import 'playlist_options_sheet.dart';

class PlaylistGridItem extends StatelessWidget {
  final Playlist playlist;

  const PlaylistGridItem({super.key, required this.playlist});
  void _navigateToPlaylistDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _playPlaylist(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);

    if (playlist.items.isNotEmpty) {
      provider.playPlaylist(playlist);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.play_circle_filled, color: Colors.white),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  '${AppStrings.playingPlaylist} "${playlist.name}"',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          margin: const EdgeInsets.all(AppConstants.smallPadding),
          action: SnackBarAction(
            label: 'VER',
            onPressed: () => _navigateToPlaylistDetail(context),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.playlistEmptyMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      builder: (context) => PlaylistOptionsSheet(playlist: playlist),
    );
  }

  Widget _buildDefaultCoverGradient(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.queue_music_rounded,
          size: 48,
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _navigateToPlaylistDetail(context),
      borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  playlist.coverArt != null
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/images/placeholder_cover.png',
                          image: playlist.coverArt!,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return _buildDefaultCoverGradient(theme);
                          },
                        )
                      : _buildDefaultCoverGradient(theme),

                  if (playlist.items.isNotEmpty)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _playPlaylist(context),
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(
                            AppConstants.smallPadding,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: AppConstants.smallIconSize,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.itemCount} ${playlist.itemCount == 1 ? 'música' : 'músicas'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (playlist.description != null &&
                        playlist.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        playlist.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
