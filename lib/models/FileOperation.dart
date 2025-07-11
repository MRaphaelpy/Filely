import 'package:Filely/models/FileOperationType.dart';

class FileOperation {
  final String sourcePath;
  final FileOperationType type;
  final bool isDirectory;

  FileOperation({
    required this.sourcePath,
    required this.type,
    required this.isDirectory,
  });
}