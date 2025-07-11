import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({Key? key, required this.mediaItem, required this.isPlaying})
    : super(key: key);

  final MediaItem mediaItem;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
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
}
