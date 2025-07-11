import 'package:flutter/material.dart';
import '../../../../models/playlist_models.dart';
import '../../../../providers/playlist_provider.dart';

class PlaylistsRenameDialog extends StatefulWidget {
  final Playlist playlist;
  final PlaylistProvider provider;

  const PlaylistsRenameDialog({
    super.key,
    required this.playlist,
    required this.provider,
  });

  @override
  State<PlaylistsRenameDialog> createState() => _PlaylistsRenameDialogState();
}

class _PlaylistsRenameDialogState extends State<PlaylistsRenameDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playlist.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Renomear Playlist'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Nome da playlist',
            hintText: 'Digite o novo nome',
            prefixIcon: const Icon(Icons.playlist_play),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome não pode estar vazio';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleSubmit(),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.provider.renamePlaylist(
        widget.playlist.id,
        _controller.text.trim(),
      );
      Navigator.of(context).pop(true);
    }
  }
}
