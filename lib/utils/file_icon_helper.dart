import 'package:flutter/material.dart';

class FileIconHelper {
  static final Map<String, IconData> _fileIcons = {
    'audio': Icons.music_note,
    'video': Icons.video_file,
    'pdf': Icons.picture_as_pdf,
    'document': Icons.description,
    'archive': Icons.archive,
    'apk': Icons.android,
    'default': Icons.insert_drive_file,
  };

  static final Map<String, Color> _fileColors = {
    'audio': Colors.purple,
    'video': Colors.red,
    'pdf': Colors.red,
    'document': Colors.blue,
    'archive': Colors.brown,
    'apk': Colors.green,
    'default': Colors.blue,
  };

  static final Map<String, List<String>> _fileExtensions = {
    'audio': ['mp3', 'wav', 'ogg', 'aac', 'flac'],
    'video': ['mp4', 'avi', 'mov', 'mkv', 'flv', 'webm', '3gp', 'wmv'],
    'pdf': ['pdf'],
    'document': ['doc', 'docx', 'txt', 'rtf'],
    'archive': ['zip', 'rar', '7z', 'tar', 'gz'],
    'apk': ['apk'],
  };

  static Widget getIconForFileType(bool isDirectory, String fileExtension) {
    if (isDirectory) {
      return Icon(Icons.folder, color: Colors.amber, size: 36);
    }
    fileExtension = fileExtension.toLowerCase();

    String fileType =
        _fileExtensions.entries
            .firstWhere(
              (entry) => entry.value.contains(fileExtension),
              orElse: () => MapEntry('default', []),
            )
            .key;
    IconData fileIcon = _fileIcons[fileType] ?? _fileIcons['default']!;
    Color fileColor = _fileColors[fileType] ?? _fileColors['default']!;

    return Icon(fileIcon, color: fileColor, size: 36);
  }
}
