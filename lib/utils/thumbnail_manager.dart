import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ThumbnailManager {
  Future<File> compressImageFile(
    File file, {
    int quality = 70,
    int minWidth = 100,
    int minHeight = 100,
  }) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );

    final tempDir = await getTemporaryDirectory();
    final compressedPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = File(compressedPath);
    await compressedFile.writeAsBytes(result!);
    return compressedFile;
  }

  bool isImage(String path) {
    final fileExtension = _getFileExtension(path);
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageExtensions.contains(fileExtension);
  }

  bool isAudio(String filePath) {
    final audioExtensions = ['mp3', 'wav', 'aac', 'flac', 'ogg'];
    final fileExtension = filePath.split('.').last.toLowerCase();
    return audioExtensions.contains(fileExtension);
  }

  bool isVideo(String path) {
    final fileExtension = _getFileExtension(path);
    final videoExtensions = [
      'mp4',
      'avi',
      'mov',
      'mkv',
      'flv',
      'webm',
      '3gp',
      'wmv',
    ];
    return videoExtensions.contains(fileExtension);
  }

  String _getFileExtension(String path) {
    final fileName = path.split('/').last;
    return fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
  }
}
