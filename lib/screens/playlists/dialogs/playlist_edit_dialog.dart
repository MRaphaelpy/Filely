import 'package:flutter/material.dart';
import '../../../providers/playlist_provider.dart';

class PlaylistEditDialog extends StatelessWidget {
  final String playlistId;
  final String currentName;
  final String? currentDescription;
  final PlaylistProvider provider;
  final VoidCallback onSuccess;

  const PlaylistEditDialog({
    super.key,
    required this.playlistId,
    required this.currentName,
    this.currentDescription,
    required this.provider,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: currentName);
    final descriptionController = TextEditingController(
      text: currentDescription ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Editar Playlist'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
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
              controller: descriptionController,
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
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final newName = nameController.text.trim();
              final newDescription = descriptionController.text.trim();

              provider.updatePlaylist(
                playlistId,
                newName,
                newDescription.isEmpty ? '' : newDescription,
              );
              Navigator.of(context).pop();
              onSuccess();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
