import 'package:flutter/material.dart';

import '../../../models/playlist_models.dart';
import '../../../providers/playlist_provider.dart';

class PlaylistDetailEditDialog extends StatefulWidget {
  final Playlist playlist;
  final PlaylistProvider provider;

  const PlaylistDetailEditDialog({
    super.key,
    required this.playlist,
    required this.provider,
  });

  @override
  State<PlaylistDetailEditDialog> createState() =>
      _PlaylistDetailEditDialogState();
}

class _PlaylistDetailEditDialogState extends State<PlaylistDetailEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
    _descriptionController = TextEditingController(
      text: widget.playlist.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Editar Playlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da playlist',
                prefixIcon: const Icon(Icons.playlist_play),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome não pode estar vazio';
                }
                return null;
              },
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
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
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final newDescription = _descriptionController.text.trim();

      widget.provider.updatePlaylist(
        widget.playlist.id,
        newName,
        newDescription.isEmpty ? '' : newDescription,
      );
      Navigator.of(context).pop(true);
    }
  }
}
