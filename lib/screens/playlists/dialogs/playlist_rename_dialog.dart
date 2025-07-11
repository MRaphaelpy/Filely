import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../models/playlist_models.dart';
import '../../../providers/playlist_provider.dart';

class PlaylistRenameDialog extends StatefulWidget {
  final Playlist playlist;

  const PlaylistRenameDialog({super.key, required this.playlist});

  @override
  State<PlaylistRenameDialog> createState() => _PlaylistRenameDialogState();
}

class _PlaylistRenameDialogState extends State<PlaylistRenameDialog> {
  late final TextEditingController _controller;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PlaylistProvider>(context, listen: false);
      provider.renamePlaylist(widget.playlist.id, _controller.text.trim());
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playlist renomeada com sucesso'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    }
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome não pode estar vazio';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel(context),
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
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
