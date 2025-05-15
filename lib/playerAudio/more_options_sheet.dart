import 'package:flutter/material.dart';

class MoreOptionsSheet extends StatelessWidget {
  final double playbackSpeed;
  final VoidCallback onChangePlaybackSpeed;
  final VoidCallback onShare;
  final VoidCallback onAddToPlaylist;

  const MoreOptionsSheet({
    Key? key,
    required this.playbackSpeed,
    required this.onChangePlaybackSpeed,
    required this.onShare,
    required this.onAddToPlaylist,
  }) : super(key: key);

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
            onAddToPlaylist();
          },
        ),
      ],
    );
  }
}
