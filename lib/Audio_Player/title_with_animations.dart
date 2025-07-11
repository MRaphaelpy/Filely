import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TitleWithAnimations extends StatelessWidget {
  const TitleWithAnimations({
    Key? key,
    required this.title,
    required this.textTheme,
    required this.colorScheme,
    required this.isPlaying,
  }) : super(key: key);

  final String title;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
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
}
