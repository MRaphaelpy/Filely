import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String waPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';

  static const List<String> _ignoredPaths = [
    '/storage/emulated/0/Android',
    '/data/user',
    '/system',
    '/proc',
    '/dev',
    '/sys',
  ];

  static List<Directory>? _storageListCache;

  static List<FileSystemEntity>? _recentFilesCache;
  static DateTime? _recentFilesCacheTime;

  static const Map<String, List<String>> fileFormats = {
    'image': ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif'],
    'video': ['mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv', '3gp', 'webm'],
    'audio': ['mp3', 'wav', 'ogg', 'aac', 'flac', 'm4a', 'wma'],
    'document': [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'rtf',
      'odt',
      'ods',
      'odp',
    ],
    'archive': ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'],
    'app': ['apk', 'xapk'],
  };

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return '0 KB';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();

    if (decimals <= 0) {
      return '${(bytes / pow(1024, i)).round()} ${suffixes[i]}';
    }

    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String getMime(String path) {
    return mime(path) ?? '';
  }

  static String getFileType(String path) {
    final ext = extension(path).toLowerCase().replaceAll('.', '');

    for (final entry in fileFormats.entries) {
      if (entry.value.contains(ext)) {
        return entry.key;
      }
    }

    return 'other';
  }

  static Future<List<Directory>> getStorageList({bool useCache = true}) async {
    if (_storageListCache != null && useCache) {
      return _storageListCache!;
    }

    try {
      final paths = await getExternalStorageDirectories();
      if (paths == null || paths.isEmpty) {
        return [];
      }

      final filteredPaths = paths
          .map((dir) => _removeDataDirectory(dir.path))
          .toList();

      _storageListCache = filteredPaths;
      return filteredPaths;
    } catch (e) {
      print('Erro ao obter lista de armazenamento: $e');
      return [];
    }
  }

  static Directory _removeDataDirectory(String path) {
    final rootPath = path.split('Android')[0];
    return Directory(rootPath);
  }

  static bool isHidden(FileSystemEntity file) {
    return basename(file.path).startsWith('.');
  }

  static Future<List<FileSystemEntity>> getFilesInPath(
    String path, {
    bool showHidden = false,
    bool recursive = false,
  }) async {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        return [];
      }

      if (recursive) {
        return await getAllFilesInPath(path, showHidden: showHidden);
      }

      final entities = dir.listSync();
      if (!showHidden) {
        return entities.where((entity) => !isHidden(entity)).toList();
      }

      return entities;
    } catch (e) {
      print('Erro ao listar arquivos em $path: $e');
      return [];
    }
  }

  static Future<List<FileSystemEntity>> getAllFiles({
    bool showHidden = false,
    bool useCache = false,
  }) async {
    final storages = await getStorageList(useCache: useCache);
    final files = <FileSystemEntity>[];

    final futures = <Future<List<FileSystemEntity>>>[];

    for (final dir in storages) {
      futures.add(
        Future(() async {
          try {
            return await getAllFilesInPath(dir.path, showHidden: showHidden);
          } catch (e) {
            print('Erro ao escanear ${dir.path}: $e');
            return <FileSystemEntity>[];
          }
        }),
      );
    }

    final results = await Future.wait(futures);
    for (final result in results) {
      files.addAll(result);
    }

    return files;
  }

  static Future<List<FileSystemEntity>> getRecentFiles({
    bool showHidden = false,
    bool useCache = true,
    int maxFiles = 100,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    if (useCache &&
        _recentFilesCache != null &&
        _recentFilesCacheTime != null &&
        now.difference(_recentFilesCacheTime!) < cacheDuration) {
      return _recentFilesCache!;
    }

    final storages = await getStorageList();
    final recentFilesByStorage = <FileSystemEntity>[];

    for (final storage in storages) {
      try {
        final dirFiles = await _getRecentFilesFromStorage(
          storage.path,
          showHidden: showHidden,
          maxFiles: maxFiles ~/ storages.length,
        );
        recentFilesByStorage.addAll(dirFiles);
      } catch (e) {
        print('Erro ao obter arquivos recentes de ${storage.path}: $e');
      }
    }

    recentFilesByStorage.sort((a, b) {
      try {
        return b.statSync().modified.compareTo(a.statSync().modified);
      } catch (_) {
        return 0;
      }
    });

    final result = recentFilesByStorage.take(maxFiles).toList();

    _recentFilesCache = result;
    _recentFilesCacheTime = now;

    return result;
  }

  static Future<List<FileSystemEntity>> _getRecentFilesFromStorage(
    String path, {
    bool showHidden = false,
    int maxFiles = 50,
    int maxDepth = 4,
  }) async {
    final files = <FileSystemEntity>[];
    final queue = <_PathWithDepth>[_PathWithDepth(path, 0)];

    while (queue.isNotEmpty && files.length < maxFiles) {
      final current = queue.removeAt(0);

      if (current.depth > maxDepth) continue;

      if (_shouldIgnorePath(current.path)) continue;

      try {
        final dir = Directory(current.path);
        if (!dir.existsSync()) continue;

        final entities = dir.listSync();

        for (final entity in entities) {
          if (!showHidden && isHidden(entity)) continue;

          if (entity is File) {
            files.add(entity);

            if (files.length >= maxFiles) break;
          } else if (entity is Directory && current.depth < maxDepth) {
            queue.add(_PathWithDepth(entity.path, current.depth + 1));
          }
        }
      } catch (e) {}
    }

    return files;
  }

  static bool _shouldIgnorePath(String path) {
    for (final ignoredPath in _ignoredPaths) {
      if (path.contains(ignoredPath)) {
        return true;
      }
    }
    return false;
  }

  static Future<List<FileSystemEntity>> searchFiles(
    String query, {
    bool showHidden = false,
    int maxResults = 100,
    List<String>? searchExtensions,
  }) async {
    if (query.isEmpty) return [];

    final normalizedQuery = query.toLowerCase();
    final storage = await getStorageList();
    final results = <FileSystemEntity>[];
    final futures = <Future<void>>[];

    final resultCount = _Semaphore(maxResults);

    for (final dir in storage) {
      futures.add(
        _searchInDirectory(
          dir.path,
          normalizedQuery,
          showHidden,
          results,
          resultCount,
          searchExtensions,
        ),
      );
    }

    await Future.wait(futures);
    return results;
  }

  static Future<void> _searchInDirectory(
    String path,
    String query,
    bool showHidden,
    List<FileSystemEntity> results,
    _Semaphore resultCount,
    List<String>? searchExtensions,
  ) async {
    if (resultCount.isComplete() || _shouldIgnorePath(path)) {
      return;
    }

    try {
      final dir = Directory(path);
      if (!dir.existsSync()) return;

      final entities = dir.listSync();
      final subdirFutures = <Future<void>>[];

      for (final entity in entities) {
        if (resultCount.isComplete()) break;

        final fileName = basename(entity.path).toLowerCase();

        if (!showHidden && fileName.startsWith('.')) continue;

        if (fileName.contains(query)) {
          if (searchExtensions != null && entity is File) {
            final fileExt = extension(fileName).replaceAll('.', '');
            if (!searchExtensions.contains(fileExt)) continue;
          }

          if (resultCount.acquire()) {
            results.add(entity);
          } else {
            break;
          }
        }

        if (entity is Directory && !_shouldIgnorePath(entity.path)) {
          subdirFutures.add(
            _searchInDirectory(
              entity.path,
              query,
              showHidden,
              results,
              resultCount,
              searchExtensions,
            ),
          );
        }
      }

      if (!resultCount.isComplete() && subdirFutures.isNotEmpty) {
        await Future.wait(subdirFutures);
      }
    } catch (e) {}
  }

  static Future<List<FileSystemEntity>> getAllFilesInPath(
    String path, {
    bool showHidden = false,
  }) async {
    final files = <FileSystemEntity>[];

    try {
      final dir = Directory(path);
      if (!dir.existsSync()) return [];

      final entities = dir.listSync();

      for (final entity in entities) {
        if (_shouldIgnorePath(entity.path)) continue;

        if (entity is File) {
          if (showHidden || !isHidden(entity)) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          if (showHidden || !isHidden(entity)) {
            files.addAll(
              await getAllFilesInPath(entity.path, showHidden: showHidden),
            );
          }
        }
      }
    } catch (e) {}

    return files;
  }

  static String formatTime(String iso) {
    try {
      final date = DateTime.parse(iso);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final fileDate = DateTime(date.year, date.month, date.day);

      const timeFormat = 'HH:mm';
      const fullFormat = 'MMM dd, HH:mm';

      if (fileDate == today) {
        return 'Today ${DateFormat(timeFormat).format(date)}';
      } else if (fileDate == yesterday) {
        return 'Yesterday ${DateFormat(timeFormat).format(date)}';
      } else {
        return DateFormat(fullFormat).format(date);
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  static List<FileSystemEntity> sortList(
    List<FileSystemEntity> list,
    int sort,
  ) {
    final directories = <Directory>[];
    final files = <File>[];

    for (final entity in list) {
      if (entity is Directory) {
        directories.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    _sortEntities(directories, sort);
    _sortEntities(files, sort);

    return [...directories, ...files];
  }

  static void _sortEntities(List<FileSystemEntity> entities, int sort) {
    switch (sort) {
      case 0:
        entities.sort(
          (a, b) => basename(
            a.path,
          ).toLowerCase().compareTo(basename(b.path).toLowerCase()),
        );
        break;

      case 1:
        entities.sort(
          (a, b) => basename(
            b.path,
          ).toLowerCase().compareTo(basename(a.path).toLowerCase()),
        );
        break;

      case 2:
        entities.sort((a, b) {
          try {
            return a.statSync().modified.compareTo(b.statSync().modified);
          } catch (_) {
            return 0;
          }
        });
        break;

      case 3:
        entities.sort((a, b) {
          try {
            return b.statSync().modified.compareTo(a.statSync().modified);
          } catch (_) {
            return 0;
          }
        });
        break;

      case 4:
        if (entities.isNotEmpty && entities.first is File) {
          entities.sort((a, b) {
            try {
              return b.statSync().size.compareTo(a.statSync().size);
            } catch (_) {
              return 0;
            }
          });
        }
        break;

      case 5:
        if (entities.isNotEmpty && entities.first is File) {
          entities.sort((a, b) {
            try {
              return a.statSync().size.compareTo(b.statSync().size);
            } catch (_) {
              return 0;
            }
          });
        }
        break;
      default:
        entities.sort();
    }
  }
}

class _PathWithDepth {
  final String path;
  final int depth;

  _PathWithDepth(this.path, this.depth);
}

class _Semaphore {
  int _count;
  final int _maxCount;

  _Semaphore(this._maxCount) : _count = 0;

  bool acquire() {
    if (_count < _maxCount) {
      _count++;
      return true;
    }
    return false;
  }

  bool isComplete() => _count >= _maxCount;
}
