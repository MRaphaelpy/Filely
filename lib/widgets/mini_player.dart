import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import '../providers/playlist_provider.dart';
import '../playerAudio/audio_player_screen.dart';
import '../main.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        if (!mediaSnapshot.hasData || mediaSnapshot.data == null) {
          return const SizedBox.shrink();
        }

        final mediaItem = mediaSnapshot.data!;

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackSnapshot) {
            final isPlaying = playbackSnapshot.data?.playing ?? false;

            return Consumer<PlaylistProvider>(
              builder: (context, playlistProvider, child) {
                return Container(
                  height: 72,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openFullPlayer(context, mediaItem),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            _buildAlbumArt(context, mediaItem, isPlaying),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mediaItem.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (mediaItem.artist != null)
                                    Text(
                                      mediaItem.artist!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (playlistProvider.hasPrevious)
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous),
                                    onPressed: () =>
                                        playlistProvider.previousTrack(),
                                    iconSize: 24,
                                  ),

                                _buildPlayPauseButton(context, isPlaying),

                                if (playlistProvider.hasNext)
                                  IconButton(
                                    icon: const Icon(Icons.skip_next),
                                    onPressed: () =>
                                        playlistProvider.nextTrack(),
                                    iconSize: 24,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumArt(
    BuildContext context,
    MediaItem mediaItem,
    bool isPlaying,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: mediaItem.artUri != null
            ? Image.network(
                mediaItem.artUri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultArt(context, isPlaying);
                },
              )
            : _buildDefaultArt(context, isPlaying),
      ),
    );
  }

  Widget _buildDefaultArt(BuildContext context, bool isPlaying) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.music_note,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        if (isPlaying)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, bool isPlaying) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          if (isPlaying) {
            audioHandler.pause();
          } else {
            audioHandler.play();
          }
        },
        iconSize: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _openFullPlayer(BuildContext context, MediaItem mediaItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(
          title: mediaItem.title,
          artist: mediaItem.artist ?? 'Artista Desconhecido',
          albumArtUrl: mediaItem.artUri?.toString() ?? '',
          audioUrl: mediaItem.id,
          syncWithCurrentTrack: true,
        ),
      ),
    );
  }
}
