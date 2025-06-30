import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class MediaItem {
  final String id;
  final String title;
  final String? description;
  final String filePath;
  final DateTime createdAt;
  final String? thumbnailPath;

  MediaItem({
    required this.id,
    required this.title,
    this.description,
    required this.filePath,
    required this.createdAt,
    this.thumbnailPath,
  });
}

void showOptionsBottomSheet(
  BuildContext context, {
  required MediaItem item,
  required Function(MediaItem) onDelete,
  required VoidCallback onDeleteComplete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder:
        (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade300,
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Compartilhar'),
                  subtitle: const Text('Enviar para outras pessoas'),
                  onTap: () => _shareItem(context, item),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  title: const Text('Excluir'),
                  subtitle: const Text('Remover permanentemente'),
                  onTap:
                      () => _confirmDelete(
                        context,
                        item,
                        onDelete,
                        onDeleteComplete,
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Informações'),
                  subtitle: const Text('Ver detalhes'),
                  onTap: () => _showItemInfo(context, item),
                ),
              ],
            ),
          ),
        ),
  );
}

void _shareItem(BuildContext context, MediaItem item) {
  Navigator.pop(context);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Preparando para compartilhar...'),
      duration: Duration(seconds: 1),
    ),
  );

  final file = File(item.filePath);
  if (file.existsSync()) {
    Share.shareXFiles(
          [XFile(item.filePath)],
          text: item.description ?? 'Confira este item: ${item.title}',
          subject: item.title,
        )
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item compartilhado com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao compartilhar: ${error.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Arquivo não encontrado'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void _confirmDelete(
  BuildContext context,
  MediaItem item,
  Function(MediaItem) onDelete,
  VoidCallback onDeleteComplete,
) {
  Navigator.pop(context);

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Tem certeza que deseja excluir "${item.title}"? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Excluindo...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  final file = File(item.filePath);
                  if (file.existsSync()) {
                    file.deleteSync();
                  }

                  if (item.thumbnailPath != null) {
                    final thumbnail = File(item.thumbnailPath!);
                    if (thumbnail.existsSync()) {
                      thumbnail.deleteSync();
                    }
                  }

                  onDelete(item);
                  onDeleteComplete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Item excluído com sucesso'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('EXCLUIR'),
            ),
          ],
        ),
  );
}

void _showItemInfo(BuildContext context, MediaItem item) {
  Navigator.pop(context);

  final file = File(item.filePath);
  String fileSize = 'Arquivo não encontrado';
  if (file.existsSync()) {
    final sizeInBytes = file.lengthSync();
    if (sizeInBytes < 1024 * 1024) {
      fileSize = '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      fileSize = '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.thumbnailPath != null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(item.thumbnailPath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  'Informações',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                _infoRow('Nome', item.title),
                if (item.description != null && item.description!.isNotEmpty)
                  _infoRow('Descrição', item.description!),
                _infoRow('Data de criação', _formatDate(item.createdAt)),
                _infoRow('Tamanho', fileSize),
                _infoRow('Caminho', item.filePath),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('FECHAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
