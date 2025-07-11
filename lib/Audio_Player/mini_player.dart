import 'package:audio_service/audio_service.dart';
import 'package:filely/Audio_Player/album_art.dart';
import 'package:filely/Audio_Player/play_pause_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'audio_player_screen.dart';
import '../providers/playlist_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

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
                            AlbumArt(
                              mediaItem: mediaItem,
                              isPlaying: isPlaying,
                            ),
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
                                PlayPauseButton(isPlaying: isPlaying),
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
