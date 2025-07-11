import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MusicInfoWidget extends StatelessWidget {
  final String title;
  final String artist;
  final String? albumTitle;
  final ImageProvider? albumArt;
  final bool isPlaying;
  final VoidCallback? onTitleTap;
  final VoidCallback? onArtistTap;

  const MusicInfoWidget({
    super.key,
    required this.title,
    required this.artist,
    this.albumTitle,
    this.albumArt,
    this.isPlaying = false,
    this.onTitleTap,
    this.onArtistTap,
  });

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
                child: _titleWithAnimations(textTheme, colorScheme),
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

          if (isPlaying)
            Padding(
              padding: EdgeInsets.only(
                top: this.albumArt != null ? 16.0 : 24.0,
              ),
              child: _buildMusicWaveAnimation(colorScheme),
            ),

          if (albumArt != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: _buildAlbumArtPreview(context),
            ),
        ],
      ),
    );
  }

  Widget _titleWithAnimations(TextTheme textTheme, ColorScheme colorScheme) {
    final titleWidget = Text(
      title,
      style: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        height: 1.1,
        letterSpacing: -0.5,
        shadows: isPlaying
            ? [
                Shadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    if (!isPlaying) return titleWidget;
    return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.onSurface.withValues(alpha: 0.9),
                colorScheme.primary,
                colorScheme.onSurface.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: titleWidget,
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 3.seconds, delay: 2.seconds)
        .animate()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.03, 1.03),
          duration: 2.seconds,
        )
        .then()
        .scale(
          begin: const Offset(1.03, 1.03),
          end: const Offset(1.0, 1.0),
          duration: 2.seconds,
        );
  }

  Widget _buildMusicWaveAnimation(ColorScheme colorScheme) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(12, (index) {
          final double height = [
            0.3,
            0.5,
            0.7,
            0.9,
            0.7,
            0.6,
            0.8,
            0.5,
            0.3,
            0.7,
            0.8,
            0.5,
          ][index % 12];
          final delay = (index * 100).ms;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child:
                Container(
                      width: 3,
                      height: 24 * height,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleY(
                      begin: height,
                      end: height > 0.5 ? height - 0.4 : height + 0.4,
                      duration: (800 + (index * 50)).ms,
                      curve: Curves.easeInOut,
                      delay: delay,
                    ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildAlbumArtPreview(BuildContext context) {
    return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: 'album_art_$title',
              child: Image(image: albumArt!, fit: BoxFit.cover),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
