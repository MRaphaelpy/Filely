import 'dart:io';
import 'package:filely/fileList/file_explorer_controller.dart';
import 'package:filely/fileList/file_list_item.dart';
import 'package:filely/imageViewer/image_viewer.dart';
import 'package:filely/playerAudio/audio_player_screen.dart';
import 'package:flutter/material.dart';

class FileListView extends StatelessWidget {
  final List<FileSystemEntity> files;
  final FileExplorerController controller;
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
            if (isDirectory) {
              controller.navigateToDirectory(fileEntity);
            } else if (_isAudioFile(fileEntity.path)) {
              _openAudioPlayer(context, fileEntity);
            } else if (_isImageFile(fileEntity.path)) {
              _openImageViewer(context, fileEntity);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Arquivo: ${fileEntity.path.split('/').last}'),
                ),
              );
            }
          },
          onLongPress: (fileEntity, isDirectory) {
            _showContextMenu(context, fileEntity);
          },
        );
      },
    );
  }

  bool _isAudioFile(String filePath) {
    final fileExtension = filePath.split('.').last.toLowerCase();
    const audioExtensions = ['mp3', 'wav', 'ogg', 'aac', 'flac'];
    return audioExtensions.contains(fileExtension);
  }

  bool _isImageFile(String filePath) {
    final fileExtension = filePath.split('.').last.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  void _openAudioPlayer(BuildContext context, FileSystemEntity fileEntity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AudioPlayerScreen(
              title: fileEntity.path.split('/').last,
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
              title: fileEntity.path.split('/').last,
              subtitle: 'Visualizador de Imagem',
              immersiveMode: true,
            ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, FileSystemEntity fileEntity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renomear'),
              onTap: () {
                Navigator.pop(context);
                // Implementar lógica de renomear
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Mover'),
              onTap: () {
                Navigator.pop(context);
                // Implementar lógica de mover
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                // Implementar lógica de compartilhar
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Propriedades'),
              onTap: () {
                Navigator.pop(context);
                // Implementar lógica de exibir propriedades
              },
            ),
          ],
        );
      },
    );
  }
}
