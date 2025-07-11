import 'dart:io';
import 'package:Filely/models/FileOperation.dart';
import 'package:Filely/models/FileOperationType.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class FileOperationsProvider extends ChangeNotifier {
  FileOperation? _pendingOperation;
  bool _isProcessing = false;

  FileOperation? get pendingOperation => _pendingOperation;
  bool get isProcessing => _isProcessing;
  bool get hasPendingOperation => _pendingOperation != null;

  void copyFile(String filePath) {
    final isDirectory = FileSystemEntity.isDirectorySync(filePath);
    _pendingOperation = FileOperation(
      sourcePath: filePath,
      type: FileOperationType.copy,
      isDirectory: isDirectory,
    );
    notifyListeners();
  }

  void cutFile(String filePath) {
    final isDirectory = FileSystemEntity.isDirectorySync(filePath);
    _pendingOperation = FileOperation(
      sourcePath: filePath,
      type: FileOperationType.cut,
      isDirectory: isDirectory,
    );
    notifyListeners();
  }

  Future<bool> pasteFile(String destinationPath) async {
    if (_pendingOperation == null) return false;

    _isProcessing = true;
    notifyListeners();

    try {
      final sourceName = path.basename(_pendingOperation!.sourcePath);
      final destinationFilePath = path.join(destinationPath, sourceName);

      if (await _destinationExists(destinationFilePath)) {
        final newPath = await _generateUniqueName(destinationFilePath);
        await _performOperation(_pendingOperation!.sourcePath, newPath);
      } else {
        await _performOperation(
          _pendingOperation!.sourcePath,
          destinationFilePath,
        );
      }

      if (_pendingOperation!.type == FileOperationType.cut) {
        _pendingOperation = null;
      }

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      throw e;
    }
  }

  void cancelOperation() {
    _pendingOperation = null;
    notifyListeners();
  }

  Future<bool> _destinationExists(String destinationPath) async {
    return await FileSystemEntity.type(destinationPath) !=
        FileSystemEntityType.notFound;
  }

  Future<String> _generateUniqueName(String originalPath) async {
    final directory = path.dirname(originalPath);
    final fileName = path.basenameWithoutExtension(originalPath);
    final extension = path.extension(originalPath);

    int counter = 1;
    String newPath;

    do {
      final newName = extension.isNotEmpty
          ? '$fileName ($counter)$extension'
          : '$fileName ($counter)';
      newPath = path.join(directory, newName);
      counter++;
    } while (await _destinationExists(newPath));

    return newPath;
  }
  Future<void> _performOperation(
    String sourcePath,
    String destinationPath,
  ) async {
    if (_pendingOperation!.isDirectory) {
      await _copyDirectory(sourcePath, destinationPath);
      if (_pendingOperation!.type == FileOperationType.cut) {
        await Directory(sourcePath).delete(recursive: true);
      }
    } else {
      final sourceFile = File(sourcePath);

      if (_pendingOperation!.type == FileOperationType.copy) {
        await sourceFile.copy(destinationPath);
      } else {
        await sourceFile.rename(destinationPath);
      }
    }
  }
  Future<void> _copyDirectory(String sourcePath, String destinationPath) async {
    final sourceDir = Directory(sourcePath);
    final destinationDir = Directory(destinationPath);
    await destinationDir.create(recursive: true);

    await for (final entity in sourceDir.list(recursive: false)) {
      final newPath = path.join(destinationPath, path.basename(entity.path));

      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity.path, newPath);
      }
    }
  }

  Future<bool> moveFile(String sourcePath, String destinationPath) async {
    cutFile(sourcePath);
    return await pasteFile(destinationPath);
  }
  String? getPendingOperationInfo() {
    if (_pendingOperation == null) return null;

    final fileName = path.basename(_pendingOperation!.sourcePath);
    final operationType = _pendingOperation!.type == FileOperationType.copy
        ? 'Copiado'
        : 'Recortado';
    final fileType = _pendingOperation!.isDirectory ? 'pasta' : 'arquivo';

    return '$operationType: $fileName ($fileType)';
  }
}
