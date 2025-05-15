import 'dart:io';
import 'package:filely/fileList/fileActionIcon.dart';
import 'package:filely/fileList/fileInfo.dart';
import 'package:filely/widgets/leadingThumbnail.dart';
import 'package:flutter/material.dart';
class FileListItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function(FileSystemEntity, bool) onTap;
  final Function(FileSystemEntity, bool)? onLongPress;

  const FileListItem({
    required this.file,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isDirectory = FileSystemEntity.isDirectorySync(file.path);
    final fileExtension = _getFileExtension(fileName, isDirectory);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.surfaceContainerHighest, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(file, isDirectory),
        onLongPress:
            onLongPress != null ? () => onLongPress!(file, isDirectory) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              LeadingThumbnail(
                file: file,
                isDirectory: isDirectory,
                fileExtension: fileExtension,
              ),
              const SizedBox(width: 16),
              FileInfo(
                fileName: fileName,
                fileExtension: fileExtension,
                isDirectory: isDirectory,
                file: file,
              ),
              if (isDirectory)
                Icon(Icons.chevron_right_rounded, color: colorScheme.primary)
              else
                FileActionIcon(fileExtension: fileExtension),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileExtension(String fileName, bool isDirectory) {
    if (fileName.contains('.') && !isDirectory) {
      return fileName.split('.').last.toLowerCase();
    }
    return '';
  }
}
