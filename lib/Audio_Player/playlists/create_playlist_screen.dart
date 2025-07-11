import 'package:filely/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/custom_form.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Nova Playlist'),
        actions: [
          _isCreating
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 20,
                    height: 20,
                    child: const CustomLoader(
                      primaryColor: Colors.white,
                      secondaryColor: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: CustomForm(
          headerIcon: Icons.playlist_play,
          fields: [
            CustomFormField(
              name: 'name',
              type: CustomFormFieldType.text,
              label: 'Nome da playlist',
              hint: 'Digite o nome da sua playlist',
              icon: Icons.edit,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome da playlist é obrigatório';
                }
                return null;
              },
              isTitle: true,
            ),
            CustomFormField(
              name: 'description',
              type: CustomFormFieldType.text,
              label: 'Descrição (opcional)',
              hint: 'Adicione uma descrição para sua playlist',
              icon: Icons.description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              isSubtitle: true,
            ),
          ],
          infoNote:
              'Após criar a playlist, você pode adicionar músicas através do menu de contexto nos arquivos de áudio.',
          infoIcon: Icons.info_outline,
          submitButtonText: 'Criar Playlist',
          cancelButtonText: 'Cancelar',
          onCancel: () => Navigator.pop(context),
          onSubmit: _handleSubmit,
          showPreview: true,
          liveUpdate: true,
        ),
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    setState(() => _isCreating = true);

    try {
      final provider = Provider.of<PlaylistProvider>(context, listen: false);

      final name = formData['name'] as String;
      final description = formData['description'] as String?;

      await provider.createPlaylist(
        name.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "$name" criada!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar playlist: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
