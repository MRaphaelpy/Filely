import 'dart:io';

import 'package:Filely/shared/widgets/custom_loader.dart';
import 'package:Filely/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;
  final bool showBorder;
  final bool useThumbnails;

  const FileIcon({
    Key? key,
    required this.file,
    this.showBorder = false,
    this.useThumbnails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String fileExtension = extension(file.path).toLowerCase();
    final String fileName = basename(file.path).toLowerCase();
    final String? mimeType = mime(fileName);
    final String type = mimeType?.split('/').first ?? '';

    return Container(
      width: 40,
      height: 40,
      decoration: showBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            )
          : null,
      child: _buildFileRepresentation(fileExtension, type, theme),
    );
  }

  Widget _buildFileRepresentation(
    String fileExt,
    String fileType,
    ThemeData theme,
  ) {
    if (_isSpecificFileType(fileExt)) {
      return _getSpecificFileIcon(fileExt, theme);
    }

    switch (fileType) {
      case 'image':
        return _buildImageThumbnail();
      case 'video':
        return _buildVideoThumbnail();
      case 'audio':
        return _buildFileTypeIcon(
          Icons.audio_file_rounded,
          Colors.blue.shade400,
          'Áudio',
        );
      case 'text':
        return _buildFileTypeIcon(
          Icons.description_rounded,
          Colors.amber.shade700,
          'Texto',
        );
      case 'application':
        if (fileExt == '.pdf') {
          return _buildFileTypeIcon(
            Icons.picture_as_pdf_rounded,
            Colors.red.shade400,
            'PDF',
          );
        } else if (['.doc', '.docx', '.odt'].contains(fileExt)) {
          return _buildFileTypeIcon(
            Icons.article_rounded,
            Colors.blue.shade700,
            'DOC',
          );
        } else if (['.xls', '.xlsx', '.ods'].contains(fileExt)) {
          return _buildFileTypeIcon(
            Icons.table_chart_rounded,
            Colors.green.shade700,
            'XLS',
          );
        } else if (['.ppt', '.pptx', '.odp'].contains(fileExt)) {
          return _buildFileTypeIcon(
            Icons.slideshow_rounded,
            Colors.orange.shade700,
            'PPT',
          );
        }
        return _buildFileTypeIcon(
          Icons.insert_drive_file_rounded,
          theme.colorScheme.primary,
          fileExt.isNotEmpty ? fileExt.substring(1).toUpperCase() : '',
        );
      default:
        return _buildGenericFileIcon(fileExt, theme);
    }
  }

  bool _isSpecificFileType(String fileExt) {
    return [
      '.apk',
      '.crdownload',
      '.zip',
      '.tar',
      '.gz',
      '.rar',
      '.7z',
      '.epub',
      '.mobi',
    ].contains(fileExt);
  }

  Widget _getSpecificFileIcon(String fileExt, ThemeData theme) {
    switch (fileExt) {
      case '.apk':
        return _buildFileTypeIcon(
          Icons.android_rounded,
          Colors.green.shade600,
          'APK',
        );
      case '.crdownload':
        return _buildFileTypeIcon(
          Icons.download_rounded,
          Colors.blue.shade500,
          'DL',
        );
      case '.zip':
      case '.tar':
      case '.gz':
      case '.rar':
      case '.7z':
        return _buildFileTypeIcon(
          Icons.archive_rounded,
          Colors.amber.shade800,
          'ZIP',
        );
      case '.epub':
      case '.mobi':
        return _buildFileTypeIcon(
          Icons.menu_book_rounded,
          Colors.indigo.shade500,
          'E-Book',
        );
      default:
        return _buildGenericFileIcon(fileExt, theme);
    }
  }

  Widget _buildImageThumbnail() {
    if (!useThumbnails) {
      return _buildFileTypeIcon(
        Icons.image_rounded,
        Colors.purple.shade400,
        'IMG',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2)),
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
          cacheHeight: 60,
          cacheWidth: 60,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) {
              return Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomLoader(
                    primaryColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    secondaryColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  ),
                ),
              );
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFileTypeIcon(
              Icons.image_rounded,
              Colors.purple.shade400,
              'IMG',
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    if (!useThumbnails) {
      return _buildFileTypeIcon(
        Icons.videocam_rounded,
        Colors.red.shade500,
        'VID',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: VideoThumbnail(path: file.path),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeIcon(IconData icon, Color color, String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        if (label.isNotEmpty)
          Positioned(
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                label.length <= 4 ? label : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenericFileIcon(String fileExt, ThemeData theme) {
    final String label = fileExt.isNotEmpty
        ? fileExt.substring(1).toUpperCase()
        : '';

    return _buildFileTypeIcon(
      Icons.insert_drive_file_rounded,
      theme.colorScheme.primary,
      label.length <= 4 ? label : '',
    );
  }
}
