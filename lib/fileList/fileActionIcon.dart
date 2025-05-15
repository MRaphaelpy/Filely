// ignore: file_names
import 'package:flutter/material.dart';

class FileActionIcon extends StatelessWidget {
  final String fileExtension;

  const FileActionIcon({super.key, required this.fileExtension});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData? iconData;

    if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(fileExtension)) {
      iconData = Icons.article_outlined;
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(fileExtension)) {
      iconData = Icons.headphones_outlined;
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      iconData = Icons.image_outlined;
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(fileExtension)) {
      iconData = Icons.play_circle_outline_rounded;
    }

    if (iconData != null) {
      return Icon(iconData, color: colorScheme.primary, size: 20);
    }

    return const SizedBox.shrink();
  }
}
