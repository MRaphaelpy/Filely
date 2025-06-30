import 'dart:io';
import 'package:filely/models/storage_item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSystemController extends ChangeNotifier {
  String _currentPath = '';
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String? _error;
  List<String> _navigationStack = [];
  StorageItem? _selectedStorage;
  final List<String> _dangerousPaths = ['/proc', '/sys', '/dev'];

  // Getters
  String get currentPath => _currentPath;
  List<FileSystemEntity> get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canGoBack => _navigationStack.isNotEmpty;
  StorageItem? get selectedStorage => _selectedStorage;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          _error = 'Permission denied to access storage';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Default to external storage if available, otherwise internal
      _selectedStorage = await getDefaultStorage();
      _currentPath = _selectedStorage!.path;
      await listFiles();
    } catch (e) {
      _error = 'Error initializing file system: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  //filesNotifier
  ValueListenable<List<FileSystemEntity>> get filesNotifier =>
      ValueNotifier<List<FileSystemEntity>>(_files);

  Future<StorageItem> getDefaultStorage() async {
    try {
      // Try to get external storage first
      final externalDirs = await getExternalStorageDirectories();
      if (externalDirs != null && externalDirs.isNotEmpty) {
        // Get the root of the first external storage
        String fullPath = externalDirs[0].path;
        String rootPath = fullPath.split('Android')[0];
        return StorageItem(
          name: 'SD Card',
          path: rootPath,
          icon: Icons.sd_storage,
          isDefault: true,
        );
      }
    } catch (_) {
      // Fall back to internal storage if external fails
    }

    // Get internal storage
    final directory = await getApplicationDocumentsDirectory();
    String rootPath = directory.path.split('Android')[0];
    return StorageItem(
      name: 'Internal Storage',
      path: rootPath,
      icon: Icons.storage,
      isDefault: true,
    );
  }

  void navigateToDirectory(FileSystemEntity file) {
    if (isNavigationSafe(file.path)) {
      _currentPath = file.path;
      listFiles();
    }
  }

  bool isNavigationSafe(String path) {
    return !_dangerousPaths.any(
      (dangerousPath) => path.startsWith(dangerousPath),
    );
  }

  bool canNavigateUp() {
    if (currentPath.isEmpty) return false;

    final parent = Directory(currentPath).parent;
    return parent.path != currentPath;
  }

  void navigateUp() {
    if (canNavigateUp()) {
      final parent = Directory(currentPath).parent;
      _currentPath = parent.path;
      listFiles();
    }
  }

  Future<List<StorageItem>> getStorageOptions() async {
    List<StorageItem> storageOptions = [];

    try {
      // Internal storage
      final directory = await getApplicationDocumentsDirectory();
      String internalRoot = directory.path.split('Android')[0];
      storageOptions.add(
        StorageItem(
          name: 'Internal Storage',
          path: internalRoot,
          icon: Icons.storage,
          isDefault: true,
        ),
      );

      // External storage if available
      final externalDirs = await getExternalStorageDirectories();
      if (externalDirs != null && externalDirs.isNotEmpty) {
        int index = 1;
        for (var dir in externalDirs) {
          String fullPath = dir.path;
          String rootPath = fullPath.split('Android')[0];

          // Skip if this is actually the same as the internal storage
          if (rootPath == internalRoot) continue;

          storageOptions.add(
            StorageItem(
              name: 'SD Card ${externalDirs.length > 1 ? index : ""}',
              path: rootPath,
              icon: Icons.sd_storage,
              isDefault: false,
            ),
          );
          index++;
        }
      }
    } catch (e) {
      print('Error getting storage options: $e');
      // Return at least internal storage as fallback
      if (storageOptions.isEmpty) {
        storageOptions.add(
          StorageItem(
            name: 'Internal Storage',
            path: '/storage/emulated/0',
            icon: Icons.storage,
            isDefault: true,
          ),
        );
      }
    }

    return storageOptions;
  }

  Future<void> setSelectedStorage(StorageItem storage) async {
    _selectedStorage = storage;
    // Reset navigation stack
    _navigationStack = [];
    _currentPath = storage.path;
    await refreshDirectory();
  }

  Future<bool> navigateBack() async {
    if (_navigationStack.isNotEmpty) {
      _currentPath = _navigationStack.removeLast();
      await listFiles();
      return true;
    }
    return false;
  }

  Future<void> refreshDirectory() async {
    await listFiles();
  }

  Future<void> listFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dir = Directory(_currentPath);
      if (!await dir.exists()) {
        _error = 'Directory does not exist';
        _files = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final entities = await dir.list().toList();

      // Sort: Directories first, then files, both in alphabetical order
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;

        if (aIsDir && !bIsDir) {
          return -1;
        } else if (!aIsDir && bIsDir) {
          return 1;
        } else {
          return path
              .basename(a.path)
              .toLowerCase()
              .compareTo(path.basename(b.path).toLowerCase());
        }
      });

      _files = entities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error listing files: $e';
      _files = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDirectory(String name) async {
    try {
      final newDirPath = path.join(_currentPath, name);
      final newDir = Directory(newDirPath);

      if (await newDir.exists()) {
        throw Exception('A directory with this name already exists');
      }

      await newDir.create();
      await refreshDirectory();
    } catch (e) {
      _error = 'Error creating directory: $e';
      notifyListeners();
      throw e;
    }
  }

  Future<bool> isPathAccessible(String path) async {
    try {
      final dir = Directory(path);
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }

  // Implement search functionality
  Future<List<FileSystemEntity>> searchFiles(String query) async {
    if (query.isEmpty) {
      return [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = <FileSystemEntity>[];
      final dir = Directory(_currentPath);

      // Only search in the current directory for simplicity
      await for (final entity in dir.list(recursive: false)) {
        final name = path.basename(entity.path).toLowerCase();
        if (name.contains(query.toLowerCase())) {
          results.add(entity);
        }
      }

      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = 'Error searching files: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Helper methods for file/directory operations
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      await refreshDirectory();
      return true;
    } catch (e) {
      _error = 'Error deleting file: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      await dir.delete(recursive: true);
      await refreshDirectory();
      return true;
    } catch (e) {
      _error = 'Error deleting directory: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> renameFileOrDirectory(String oldPath, String newName) async {
    try {
      final entity =
          FileSystemEntity.isDirectorySync(oldPath)
              ? Directory(oldPath)
              : File(oldPath);
      final newPath = path.join(path.dirname(oldPath), newName);
      await entity.rename(newPath);
      await refreshDirectory();
      return true;
    } catch (e) {
      _error = 'Error renaming: $e';
      notifyListeners();
      return false;
    }
  }

  Future<FileSystemEntity?> getFileSystemEntity(String entityPath) async {
    try {
      if (FileSystemEntity.isDirectorySync(entityPath)) {
        return Directory(entityPath);
      } else {
        return File(entityPath);
      }
    } catch (e) {
      _error = 'Error getting entity: $e';
      notifyListeners();
      return null;
    }
  }

  // Method to check if a path is a valid directory
  Future<bool> isValidDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }

  // Get directory size
  Future<int> getDirectorySize(String dirPath) async {
    int totalSize = 0;
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      _error = 'Error calculating directory size: $e';
      notifyListeners();
      return 0;
    }
  }
}
