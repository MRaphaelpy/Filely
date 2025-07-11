import 'package:flutter/material.dart';
import '../widgets/add_to_playlist_sheet.dart';

class MoreOptionsSheet extends StatelessWidget {
  final double playbackSpeed;
  final VoidCallback onChangePlaybackSpeed;
  final VoidCallback onShare;
  final VoidCallback onAddToPlaylist;
  final String? title;
  final String? artist;
  final String? audioUrl;

  const MoreOptionsSheet({
    super.key,
    required this.playbackSpeed,
    required this.onChangePlaybackSpeed,
    required this.onShare,
    required this.onAddToPlaylist,
    this.title,
    this.artist,
    this.audioUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.speed),
          title: Text('Velocidade de reprodução (${playbackSpeed}x)'),
          onTap: () {
            Navigator.pop(context);
            onChangePlaybackSpeed();
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Compartilhar'),
          onTap: () {
            Navigator.pop(context);
            onShare();
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add, color: Colors.amber),
          title: const Text('Adicionar à playlist'),
          onTap: () {
            Navigator.pop(context);
            if (title != null && artist != null && audioUrl != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => AddToPlaylistSheet(
                  title: title!,
                  artist: artist!,
                  filePath: audioUrl!,
                ),
              );
            } else {
              onAddToPlaylist();
            }
          },
        ),
      ],
    );
  }
}
