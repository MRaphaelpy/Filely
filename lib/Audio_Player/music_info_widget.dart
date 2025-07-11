import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'album_art_preview.dart';
import 'title_with_animations.dart';

class MusicInfoWidget extends StatelessWidget {
  final String title;
  final String artist;
  final String? albumTitle;
  final ImageProvider? albumArt;
  final bool isPlaying;
  final VoidCallback? onTitleTap;
  final VoidCallback? onArtistTap;

  const MusicInfoWidget({
    Key? key,
    required this.title,
    required this.artist,
    this.albumTitle,
    this.albumArt,
    this.isPlaying = false,
    this.onTitleTap,
    this.onArtistTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTitleTap,
            child: Hero(
              tag: 'music_title_$title',
              child: Material(
                color: Colors.transparent,
                child: TitleWithAnimations(
                  title: title,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  isPlaying: isPlaying,
                ),
              ),
            ),
          ),
          if (albumTitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child:
                  Text(
                        albumTitle!,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontStyle: FontStyle.italic,
                        ),
                      )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: 0.02, end: 0),
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onArtistTap,
            child: Row(
              children: [
                Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                    ),
                const SizedBox(width: 6),
                Expanded(
                  child:
                      Hero(
                            tag: 'artist_name_$artist',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                artist,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 500.ms)
                          .slideX(begin: 0.05, end: 0),
                ),
              ],
            ),
          ),

          if (albumArt != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: AlbumArtPreview(albumArt: albumArt, title: title),
            ),
        ],
      ),
    );
  }
}
