import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlbumArtPreview extends StatelessWidget {
  const AlbumArtPreview({Key? key, required this.albumArt, required this.title})
    : super(key: key);

  final ImageProvider? albumArt;
  final String title;

  @override
  Widget build(BuildContext context) {
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
