import 'dart:io';
import 'package:filely/fileList/file_explorer_controller.dart';
import 'package:filely/fileList/file_list_item.dart';
import 'package:filely/imageViewer/image_viewer.dart';
import 'package:filely/imageViewer/options_bottom_sheet_widget.dart';
import 'package:filely/playerAudio/audio_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class FileListView extends StatelessWidget {
  final List<FileSystemEntity> files;
  final FileSystemController controller;
  final Function(FileSystemEntity, bool) onFileTap;
  final Function(FileSystemEntity, bool) onFileLongPress;

  const FileListView({
    required this.files,
    required this.controller,
    required this.onFileTap,
    required this.onFileLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return FileListItem(
          file: file,
          onTap: (fileEntity, isDirectory) {
            onFileTap(fileEntity, isDirectory);
            if (isDirectory) {
              controller.navigateToDirectory(fileEntity);
            } else if (_isAudioFile(fileEntity.path)) {
              _openAudioPlayer(context, fileEntity);
            } else if (_isImageFile(fileEntity.path)) {
              _openImageViewer(context, fileEntity);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Arquivo: ${path.basename(fileEntity.path)}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onLongPress: (fileEntity, isDirectory) {
            onFileLongPress(fileEntity, isDirectory);
          },
        );
      },
    );
  }

  bool _isAudioFile(String filePath) {
    final fileExtension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');
    const audioExtensions = ['mp3', 'wav', 'ogg', 'aac', 'flac', 'm4a'];
    return audioExtensions.contains(fileExtension);
  }

  bool _isImageFile(String filePath) {
    final fileExtension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');
    const imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'heic',
    ];
    return imageExtensions.contains(fileExtension);
  }

  bool _isVideoFile(String filePath) {
    final fileExtension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');
    const videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', '3gp'];
    return videoExtensions.contains(fileExtension);
  }

  bool _isPdfFile(String filePath) {
    final fileExtension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');
    return fileExtension == 'pdf';
  }

  void _openAudioPlayer(BuildContext context, FileSystemEntity fileEntity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AudioPlayerScreen(
              title: path.basename(fileEntity.path),
              artist: 'Artista Desconhecido',
              albumArtUrl: 'https://via.placeholder.com/150',
              audioUrl: fileEntity.path,
            ),
      ),
    );
  }

  void _openImageViewer(BuildContext context, FileSystemEntity fileEntity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImageViewerM3(
              imageUrl: fileEntity.path,
              title: path.basename(fileEntity.path),
              subtitle: 'Visualizador de Imagem',
              immersiveMode: true,
            ),
      ),
    );
  }

  void _showFileContextMenu(BuildContext context, FileSystemEntity fileEntity) {
    // Criar um MediaItem para o arquivo
    final MediaItem fileItem = MediaItem(
      id: fileEntity.path,
      title: path.basename(fileEntity.path),
      description: null,
      filePath: fileEntity.path,
      createdAt:
          fileEntity is File ? fileEntity.lastModifiedSync() : DateTime.now(),
      thumbnailPath: _isImageFile(fileEntity.path) ? fileEntity.path : null,
    );

    // Usar o showOptionsBottomSheet existente
    showOptionsBottomSheet(
      context,
      item: fileItem,
      onDelete: (deletedItem) async {
        try {
          await File(deletedItem.filePath).delete();
          // Atualizar a lista de arquivos
          // controller.refreshDirectory();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir arquivo: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onDeleteComplete: () {
        // Feedback já é mostrado no showOptionsBottomSheet
      },
    );
  }

  void _showDirectoryContextMenu(
    BuildContext context,
    FileSystemEntity directory,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
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
                _buildDirectoryOptionTile(
                  context,
                  directory,
                  Icons.drive_file_rename_outline,
                  'Renomear',
                  'Alterar o nome da pasta',
                  () => _showRenameDialog(context, directory),
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primary,
                ),
                const Divider(height: 1),
                _buildDirectoryOptionTile(
                  context,
                  directory,
                  Icons.delete_outline,
                  'Excluir',
                  'Remover pasta e conteúdo',
                  () => _confirmDeleteDirectory(context, directory),
                  Theme.of(context).colorScheme.errorContainer,
                  Theme.of(context).colorScheme.error,
                ),
                const Divider(height: 1),
                _buildDirectoryOptionTile(
                  context,
                  directory,
                  Icons.info_outline,
                  'Propriedades',
                  'Ver informações da pasta',
                  () => _showDirectoryProperties(context, directory),
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDirectoryOptionTile(
    BuildContext context,
    FileSystemEntity directory,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color containerColor,
    Color iconColor,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: containerColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showRenameDialog(BuildContext context, FileSystemEntity entity) {
    final textController = TextEditingController(
      text: path.basename(entity.path),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Renomear'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um nome válido';
                  }
                  if (value.contains('/') || value.contains('\\')) {
                    return 'Nome não pode conter / ou \\';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);

                    final String newName = textController.text;
                    final String parentDir = path.dirname(entity.path);
                    final String newPath = path.join(parentDir, newName);

                    try {
                      await entity.rename(newPath);
                      //    controller.refreshDirectory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Renomeado com sucesso para "$newName"',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao renomear: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: const Text('RENOMEAR'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteDirectory(
    BuildContext context,
    FileSystemEntity directory,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Tem certeza que deseja excluir a pasta "${path.basename(directory.path)}" e todo seu conteúdo? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    // Remove o diretório recursivamente
                    if (directory is Directory) {
                      await directory.delete(recursive: true);
                    }
                    //controller.refreshDirectory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pasta excluída com sucesso'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir pasta: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('EXCLUIR'),
              ),
            ],
          ),
    );
  }

  void _showDirectoryProperties(
    BuildContext context,
    FileSystemEntity directory,
  ) {
    if (directory is! Directory) return;

    // Função assíncrona para calcular o tamanho do diretório
    Future<int> calculateDirSize(Directory dir) async {
      int totalSize = 0;
      try {
        final List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        for (var entity in entities) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      } catch (e) {
        print('Erro ao calcular tamanho do diretório: $e');
      }
      return totalSize;
    }

    // Contar arquivos e diretórios
    Future<Map<String, int>> countItems(Directory dir) async {
      int files = 0;
      int dirs = 0;
      try {
        await for (var entity in dir.list(recursive: false)) {
          if (entity is File) {
            files++;
          } else if (entity is Directory) {
            dirs++;
          }
        }
      } catch (e) {
        print('Erro ao contar itens: $e');
      }
      return {'files': files, 'dirs': dirs};
    }

    // Mostrar dialog com carregamento inicial
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Propriedades de ${path.basename(directory.path)}'),
            content: SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calculando informações...'),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FECHAR'),
              ),
            ],
          ),
    );

    // Calcular informações de forma assíncrona
    Future.wait([calculateDirSize(directory), countItems(directory)]).then((
      results,
    ) {
      final int totalSize = results[0] as int;
      final Map<String, int> counts = results[1] as Map<String, int>;

      // Formatar tamanho
      String formattedSize;
      if (totalSize < 1024) {
        formattedSize = '$totalSize B';
      } else if (totalSize < 1024 * 1024) {
        formattedSize = '${(totalSize / 1024).toStringAsFixed(2)} KB';
      } else if (totalSize < 1024 * 1024 * 1024) {
        formattedSize = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
      } else {
        formattedSize =
            '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      }

      // Fechar diálogo de carregamento
      Navigator.pop(context);

      // Mostrar diálogo com informações
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
                    Text(
                      'Propriedades da Pasta',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    _infoRow('Nome', path.basename(directory.path)),
                    _infoRow('Caminho', directory.path),
                    _infoRow('Tamanho', formattedSize),
                    _infoRow('Arquivos', '${counts['files']}'),
                    _infoRow('Pastas', '${counts['dirs']}'),
                    _infoRow(
                      'Modificado',
                      _formatDate(directory.statSync().modified),
                    ),
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
    });
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
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }
}
