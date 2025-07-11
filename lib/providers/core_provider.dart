import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:filely/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:path_provider/path_provider.dart';

class CoreProvider extends ChangeNotifier {
  List<FileSystemEntity> availableStorage = [];
  List<FileSystemEntity> recentFiles = [];
  final isolates = IsolateHandler();
  int totalSpace = 0;
  int freeSpace = 0;
  int totalSDSpace = 0;
  int freeSDSpace = 0;
  int usedSpace = 0;
  int usedSDSpace = 0;
  bool storageLoading = true;
  bool recentLoading = true;

  static const MethodChannel _platform = MethodChannel(
    'mraphaelpy.filely/storage',
  );

  Future<void> checkSpace() async {
    _setLoading(storageLoading: true, recentLoading: true);
    recentFiles.clear();
    availableStorage.clear();

    final List<Directory>? dirList = await getExternalStorageDirectories();

    if (dirList == null || dirList.isEmpty) {
      _useFallbackStorageValues();
      _setLoading(storageLoading: false);
      return;
    }

    availableStorage.addAll(dirList);
    notifyListeners();

    try {
      dynamic freeResult = await _platform.invokeMethod('getStorageFreeSpace');
      dynamic totalResult = await _platform.invokeMethod(
        'getStorageTotalSpace',
      );

      int free = _parseStorageValue(freeResult);
      int total = _parseStorageValue(totalResult);

      if (total <= 0 || free <= 0 || free > total) {
        await _tryAlternativeStorageMethod(dirList[0].path);
      } else {
        _updateStorageInfo(
          freeSpace: free,
          totalSpace: total,
          usedSpace: total - free,
        );
      }
    } catch (e) {
      await _tryAlternativeStorageMethod(dirList[0].path);
    }

    if (dirList.length > 1) {
      try {
        dynamic freeSDResult = await _platform.invokeMethod(
          'getExternalStorageFreeSpace',
        );
        dynamic totalSDResult = await _platform.invokeMethod(
          'getExternalStorageTotalSpace',
        );

        int freeSD = _parseStorageValue(freeSDResult);
        int totalSD = _parseStorageValue(totalSDResult);

        if (totalSD <= 0 || freeSD <= 0 || freeSD > totalSD) {
          await _tryAlternativeSDStorageMethod(dirList[1].path);
        } else {
          _updateSDStorageInfo(
            freeSDSpace: freeSD,
            totalSDSpace: totalSD,
            usedSDSpace: totalSD - freeSD,
          );
        }
      } catch (e) {
        await _tryAlternativeSDStorageMethod(dirList[1].path);
      }
    }

    if (totalSpace <= 0) {
      await _useFallbackStorageValues();
    }

    _setLoading(storageLoading: false);
    await getRecentFiles();
  }

  Future<void> _tryAlternativeStorageMethod(String path) async {
    try {
      final Map<String, dynamic>? result = await _platform
          .invokeMapMethod<String, dynamic>('getStorageInfo', {'path': path});

      if (result != null &&
          result.containsKey('total') &&
          result.containsKey('free')) {
        int total = _parseStorageValue(result['total']);
        int free = _parseStorageValue(result['free']);

        if (total > 0 && free >= 0 && free <= total) {
          _updateStorageInfo(
            freeSpace: free,
            totalSpace: total,
            usedSpace: total - free,
          );
          return;
        }
      }

      await _useFallbackStorageValues();
    } catch (e) {
      await _useFallbackStorageValues();
    }
  }

  Future<void> _tryAlternativeSDStorageMethod(String path) async {
    try {
      final Map<String, dynamic>? result = await _platform
          .invokeMapMethod<String, dynamic>('getStorageInfo', {'path': path});

      if (result != null &&
          result.containsKey('total') &&
          result.containsKey('free')) {
        int total = _parseStorageValue(result['total']);
        int free = _parseStorageValue(result['free']);

        if (total > 0 && free >= 0 && free <= total) {
          _updateSDStorageInfo(
            freeSDSpace: free,
            totalSDSpace: total,
            usedSDSpace: total - free,
          );
          return;
        }
      }

      _useFallbackSDStorageValues();
    } catch (e) {
      _useFallbackSDStorageValues();
    }
  }

  Future<void> _useFallbackStorageValues() async {
    try {
      DiskSpacePlus diskSpacePlus = DiskSpacePlus();
      final freeBytes = await diskSpacePlus.getFreeDiskSpace ?? 0;
      final totalBytes = await diskSpacePlus.getTotalDiskSpace;

      if (totalBytes != null && totalBytes > 0) {
        _updateStorageInfo(
          freeSpace: freeBytes.toInt(),
          totalSpace: totalBytes.toInt(),
          usedSpace: (totalBytes - freeBytes).toInt(),
        );
        return;
      }
    } catch (e) {}

    final int defaultTotal = 32 * 1024 * 1024 * 1024;
    final int defaultFree = defaultTotal ~/ 3;

    _updateStorageInfo(
      freeSpace: defaultFree,
      totalSpace: defaultTotal,
      usedSpace: defaultTotal - defaultFree,
    );
  }

  void _useFallbackSDStorageValues() {
    final int defaultTotal = 16 * 1024 * 1024 * 1024;
    final int defaultFree = defaultTotal ~/ 4;

    _updateSDStorageInfo(
      freeSDSpace: defaultFree,
      totalSDSpace: defaultTotal,
      usedSDSpace: defaultTotal - defaultFree,
    );
  }

  int _parseStorageValue(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  void _updateStorageInfo({
    required int freeSpace,
    required int totalSpace,
    required int usedSpace,
  }) {
    this.freeSpace = freeSpace;
    this.totalSpace = totalSpace;
    this.usedSpace = usedSpace;
    notifyListeners();
  }

  void _updateSDStorageInfo({
    required int freeSDSpace,
    required int totalSDSpace,
    required int usedSDSpace,
  }) {
    this.freeSDSpace = freeSDSpace;
    this.totalSDSpace = totalSDSpace;
    this.usedSDSpace = usedSDSpace;
    notifyListeners();
  }

  void _setLoading({bool? storageLoading, bool? recentLoading}) {
    if (storageLoading != null) this.storageLoading = storageLoading;
    if (recentLoading != null) this.recentLoading = recentLoading;
    notifyListeners();
  }

  Future<void> getRecentFiles() async {
    const String isolateName = 'recent';
    final ReceivePort port = ReceivePort();

    Timer? timeoutTimer;
    bool hasCompleted = false;

    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');

    timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!hasCompleted) {
        hasCompleted = true;
        _setLoading(recentLoading: false);
        port.close();
        IsolateNameServer.removePortNameMapping('${isolateName}_2');
        isolates.kill(isolateName);
        print('Timeout ao buscar arquivos recentes');
      }
    });

    port.listen((message) {
      if (!hasCompleted) {
        hasCompleted = true;
        timeoutTimer?.cancel();

        if (message is List<FileSystemEntity>) {
          recentFiles.clear();
          recentFiles.addAll(message);
        }
        _setLoading(recentLoading: false);
        port.close();
        IsolateNameServer.removePortNameMapping('${isolateName}_2');
      }
    });

    try {
      isolates.spawn<String>(
        getFilesWithIsolate,
        name: isolateName,
        onReceive: (val) {
          isolates.kill(isolateName);
        },
        onInitialized: () => isolates.send('start', to: isolateName),
      );
    } catch (e) {
      if (!hasCompleted) {
        hasCompleted = true;
        timeoutTimer.cancel();
        _setLoading(recentLoading: false);
        port.close();
        IsolateNameServer.removePortNameMapping('${isolateName}_2');
        print('Erro ao inicializar isolate para arquivos recentes: $e');
      }
    }
  }

  static Future<void> getFilesWithIsolate(Map<String, dynamic> context) async {
    final String isolateName = context['name'];
    final messenger = HandledIsolate.initialize(context);

    final List<FileSystemEntity> files = await FileUtils.getRecentFiles(
      showHidden: false,
    );
    final SendPort? sendPort = IsolateNameServer.lookupPortByName(
      '${isolateName}_2',
    );
    if (sendPort != null) {
      sendPort.send(files);
    }

    messenger.send('done');
  }

  Future<void> forceStorageRefresh() async {
    totalSpace = 0;
    freeSpace = 0;
    usedSpace = 0;
    totalSDSpace = 0;
    freeSDSpace = 0;
    usedSDSpace = 0;

    await checkSpace();
  }

  @override
  void dispose() {
    isolates.kill('recent');
    super.dispose();
  }
}
