import 'package:flutter/material.dart';

Color getFileColor(ThemeData theme, String exten) {
  final extension = exten.toLowerCase();

  if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
    return Colors.purple.shade600;
  } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(extension)) {
    return Colors.red.shade600;
  } else if (['.mp3', '.wav', '.ogg', '.m4a'].contains(extension)) {
    return Colors.blue.shade600;
  } else if (['.pdf'].contains(extension)) {
    return Colors.red.shade700;
  } else if (['.doc', '.docx', '.txt', '.rtf'].contains(extension)) {
    return Colors.blue.shade700;
  } else if (['.xls', '.xlsx', '.csv'].contains(extension)) {
    return Colors.green.shade700;
  } else if (['.ppt', '.pptx'].contains(extension)) {
    return Colors.orange.shade700;
  } else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
    return Colors.amber.shade800;
  } else if (['.apk'].contains(extension)) {
    return Colors.green.shade600;
  }

  return theme.colorScheme.primary;
}

IconData getFileIcon(String extension) {
  extension.toLowerCase();
  if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
    return Icons.image_rounded;
  } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(extension)) {
    return Icons.movie_rounded;
  } else if (['.mp3', '.wav', '.ogg', '.m4a'].contains(extension)) {
    return Icons.music_note_rounded;
  } else if (['.pdf'].contains(extension)) {
    return Icons.picture_as_pdf_rounded;
  } else if (['.doc', '.docx', '.txt', '.rtf'].contains(extension)) {
    return Icons.article_rounded;
  } else if (['.xls', '.xlsx', '.csv'].contains(extension)) {
    return Icons.table_chart_rounded;
  } else if (['.ppt', '.pptx'].contains(extension)) {
    return Icons.slideshow_rounded;
  } else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
    return Icons.archive_rounded;
  } else if (['.apk'].contains(extension)) {
    return Icons.android_rounded;
  }

  return Icons.insert_drive_file_rounded;
}
