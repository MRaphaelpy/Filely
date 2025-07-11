import 'dart:io';

import 'package:Filely/Audio_Player/audio_player_screen.dart';
import 'package:Filely/providers/file_operations_provider.dart';
import 'package:Filely/utils/utils.dart';
import 'package:Filely/widgets/add_to_playlist_sheet.dart';
import 'package:Filely/widgets/file_icon.dart';
import 'package:Filely/widgets/file_popup.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function? popTap;
  final bool showFullDate;
  final bool enableLongPress;

  const FileItem({
    Key? key,
    required this.file,
    this.popTap,
    this.showFullDate = false,
    this.enableLongPress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = basename(file.path);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openFile(context),
        onLongPress: enableLongPress ? () => _showFileOptions(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FileIcon(file: file, useThumbnails: true),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        _buildFileInfoTag(
                          _getFileSize(),
                          Icons.straighten_rounded,
                          theme.colorScheme.primary,
                          theme,
                        ),
                        const SizedBox(width: 8),
                        _buildFileInfoTag(
                          _getFileDate(),
                          Icons.access_time_rounded,
                          theme.colorScheme.secondary,
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (popTap != null) FilePopup(path: file.path, popTap: popTap!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfoTag(
    String text,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileSize() {
    try {
      final fileObj = File(file.path);
      if (fileObj.existsSync()) {
        return FileUtils.formatBytes(fileObj.lengthSync(), 1);
      }
      return '0 B';
    } catch (e) {
      return '0 B';
    }
  }

  String _getFileDate() {
    try {
      final fileObj = File(file.path);
      if (fileObj.existsSync()) {
        final modifiedDate = fileObj.lastModifiedSync();
        if (showFullDate) {
          return FileUtils.formatTime(modifiedDate.toIso8601String());
        } else {
          return timeago.format(modifiedDate, locale: 'pt_BR');
        }
      }
      return 'Desconhecido';
    } catch (e) {
      return 'Desconhecido';
    }
  }

  Future<void> _openFile(BuildContext context) async {
    if (_isAudioFile()) {
      _openAudioPlayer(context);
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abrindo arquivo...'),
          duration: Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível abrir o arquivo: ${result.message}',
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir o arquivo: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  bool _isAudioFile() {
    final fileName = basename(file.path).toLowerCase();
    final mimeType = mime(fileName) ?? '';
    final fileExtension = extension(file.path).toLowerCase();

    final audioExtensions = [
      '.mp3',
      '.wav',
      '.aac',
      '.m4a',
      '.ogg',
      '.flac',
      '.opus',
      '.wma',
    ];

    return mimeType.startsWith('audio/') ||
        audioExtensions.contains(fileExtension);
  }

  void _openAudioPlayer(BuildContext context) {
    final fileName = basenameWithoutExtension(file.path);
    final artist = 'Artista Desconhecido';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(
          title: fileName,
          artist: artist,
          albumArtUrl: '',
          audioUrl: file.path,
        ),
      ),
    );
  }

  void _showFileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFileOptionsModal(context),
    );
  }

  Widget _buildFileOptionsModal(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = basename(file.path);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FileIcon(file: file),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getFileSize(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            _buildOptionButton(context, 'Abrir', Icons.open_in_new_rounded, () {
              Navigator.of(context).pop();
              _openFile(context);
            }),

            if (_isAudioFile())
              _buildOptionButton(
                context,
                'Adicionar à playlist',
                Icons.playlist_add,
                () {
                  Navigator.of(context).pop();
                  _showAddToPlaylistSheet(context);
                },
              ),

            _buildOptionButton(context, 'Copiar', Icons.copy_rounded, () {
              Navigator.of(context).pop();
              _copyFileToClipboard(context);
            }),

            _buildOptionButton(
              context,
              'Recortar',
              Icons.content_cut_rounded,
              () {
                Navigator.of(context).pop();
                _cutFileToClipboard(context);
              },
            ),

            _buildOptionButton(
              context,
              'Compartilhar',
              Icons.share_rounded,
              () {
                Navigator.of(context).pop();
              },
            ),

            if (popTap != null)
              _buildOptionButton(
                context,
                'Mais opções',
                Icons.more_horiz_rounded,
                () {
                  Navigator.of(context).pop();
                  popTap!(file.path);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text(label, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context) {
    final fileName = basenameWithoutExtension(file.path);
    final artist = 'Artista Desconhecido';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddToPlaylistSheet(
        title: fileName,
        artist: artist,
        filePath: file.path,
        albumArt: null,
        duration: null,
      ),
    );
  }

  void _copyFileToClipboard(BuildContext context) {
    final provider = Provider.of<FileOperationsProvider>(
      context,
      listen: false,
    );
    provider.copyFile(file.path);

    final fileName = basename(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileName copiado'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cutFileToClipboard(BuildContext context) {
    final provider = Provider.of<FileOperationsProvider>(
      context,
      listen: false,
    );
    provider.cutFile(file.path);

    final fileName = basename(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileName recortado'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
