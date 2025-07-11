import 'dart:io';

import 'package:filely/widgets/dir_popup.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class DirectoryItem extends StatelessWidget {
  final FileSystemEntity file;
  final VoidCallback tap;
  final Function? popTap;
  final bool isSelected;
  final bool showItemCount;

  const DirectoryItem({
    Key? key,
    required this.file,
    required this.tap,
    this.popTap,
    this.isSelected = false,
    this.showItemCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folderName = basename(file.path);
    final itemCount = _getItemCount();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.05)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              _buildFolderIcon(theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      folderName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (showItemCount && itemCount > -1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _getItemsText(itemCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (popTap != null) DirPopup(path: file.path, popTap: popTap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderIcon(ThemeData theme) {
    final folderColor = _getFolderColor(theme);

    return Stack(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: folderColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getFolderIcon(), color: folderColor, size: 24),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: theme.colorScheme.onPrimary,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  Color _getFolderColor(ThemeData theme) {
    final path = file.path.toLowerCase();

    if (path.contains('download') || path.contains('downloads')) {
      return Colors.blue.shade600;
    } else if (path.contains('image') ||
        path.contains('photo') ||
        path.contains('picture')) {
      return Colors.purple.shade600;
    } else if (path.contains('music') || path.contains('audio')) {
      return Colors.orange.shade600;
    } else if (path.contains('video') || path.contains('movie')) {
      return Colors.red.shade600;
    } else if (path.contains('document') || path.contains('doc')) {
      return Colors.amber.shade700;
    } else if (path.contains('android') || path.contains('app')) {
      return Colors.green.shade600;
    } else {
      return theme.colorScheme.secondary;
    }
  }

  IconData _getFolderIcon() {
    final path = file.path.toLowerCase();

    if (path.contains('download')) {
      return Icons.download_rounded;
    } else if (path.contains('image') ||
        path.contains('photo') ||
        path.contains('picture')) {
      return Icons.photo_library_rounded;
    } else if (path.contains('music') || path.contains('audio')) {
      return Icons.music_note_rounded;
    } else if (path.contains('video') || path.contains('movie')) {
      return Icons.video_library_rounded;
    } else if (path.contains('document') || path.contains('doc')) {
      return Icons.description_rounded;
    } else if (path.contains('android') || path.contains('app')) {
      return Icons.android_rounded;
    } else {
      return Icons.folder_rounded;
    }
  }

  int _getItemCount() {
    try {
      final directory = Directory(file.path);
      if (directory.existsSync()) {
        return directory.listSync().length;
      }
    } catch (e) {}
    return -1;
  }

  String _getItemsText(int count) {
    if (count <= 0) {
      return 'Pasta vazia';
    } else if (count == 1) {
      return '1 item';
    } else {
      return '$count itens';
    }
  }
}
