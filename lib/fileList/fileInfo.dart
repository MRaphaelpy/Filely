import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filely/utils/file_size.dart';

class FileInfo extends StatelessWidget {
  final String fileName;
  final String fileExtension;
  final bool isDirectory;
  final FileSystemEntity file;

  const FileInfo({
    required this.fileName,
    required this.fileExtension,
    required this.isDirectory,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isDirectory
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDirectory ? 'Pasta' : fileExtension.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDirectory
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isDirectory && getFileSize(file) != null) ...[
                const SizedBox(width: 8),
                Text(
                  getFileSize(file)!,
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
