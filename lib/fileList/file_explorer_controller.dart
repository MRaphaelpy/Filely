// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/permission_manager.dart';
import '../utils/thumbnail_manager.dart';

class FileExplorerController {
  ValueNotifier<List<FileSystemEntity>> filesNotifier = ValueNotifier([]);
  String currentPath = '';
  bool hasPermission = false;
  bool isAndroid11OrHigher = false;

  final ThumbnailManager thumbnailManager = ThumbnailManager();
  final PermissionManager permissionManager = PermissionManager();
  final List<String> _dangerousPaths = ['/proc', '/sys', '/dev'];

  Future<void> initialize() async {
    isAndroid11OrHigher =
        Platform.isAndroid &&
        (await permissionManager.getAndroidSdkVersion() >= 30);

    hasPermission = await permissionManager.requestPermission();

    if (hasPermission) {
      await initDirectory();
    }
  }

  Future<void> initDirectory() async {
    try {
      Directory? directory;

      if (isAndroid11OrHigher &&
          await permissionManager.hasManageExternalStoragePermission()) {
        directory = Directory('/storage/emulated/0');
      } else {
        directory = await getExternalStorageDirectory();

        if (directory == null) {
          List<Directory>? externalDirs = await getExternalStorageDirectories();
          directory =
              externalDirs?.isNotEmpty == true
                  ? externalDirs!.first
                  : Directory('/');
        }
      }

      if (!await directory.exists()) {
        directory = await getTemporaryDirectory();
      }

      currentPath = directory.path;
      await listFiles();
    } catch (_) {}
  }

  void scrollToTop(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> listFiles() async {
    try {
      if (currentPath.isEmpty) {
        await initDirectory();
        return;
      }

      Directory directory = Directory(currentPath);

      if (await directory.exists()) {
        List<FileSystemEntity> entities = await directory.list().toList();

        filesNotifier.value = entities;
        filesNotifier.value.sort((a, b) {
          bool aIsDir = FileSystemEntity.isDirectorySync(a.path);
          bool bIsDir = FileSystemEntity.isDirectorySync(b.path);

          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;

          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

        filesNotifier.notifyListeners();
      } else {
        final parent = Directory(currentPath).parent;
        currentPath = parent.path;
        await listFiles();
      }
    } catch (_) {}
  }

  void navigateToDirectory(FileSystemEntity file) {
    if (isNavigationSafe(file.path)) {
      currentPath = file.path;
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
      currentPath = parent.path;
      listFiles();
    }
  }
}
