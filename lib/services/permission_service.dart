import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionStatus { granted, denied, permanentlyDenied, restricted }

class PermissionService {
  static const MethodChannel _platform = MethodChannel(
    'dev.flutter/androidInfo',
  );
  static Future<bool> isAndroid13OrHigher() async {
    try {
      final sdkVersion = await _platform.invokeMethod<int>(
        'getAndroidSdkVersion',
      );
      return sdkVersion != null && sdkVersion >= 33;
    } catch (e) {
      return false;
    }
  }

  static Future<AppPermissionStatus> checkStoragePermission() async {
    try {
      final isAndroid13Plus = await isAndroid13OrHigher();

      if (isAndroid13Plus) {
        if (await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.audio.isGranted) {
          return AppPermissionStatus.granted;
        }

        if (await Permission.photos.isPermanentlyDenied &&
            await Permission.videos.isPermanentlyDenied &&
            await Permission.audio.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
      } else {
        if (await Permission.storage.isGranted ||
            await Permission.manageExternalStorage.isGranted) {
          return AppPermissionStatus.granted;
        }

        if (await Permission.storage.isPermanentlyDenied &&
            await Permission.manageExternalStorage.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
      }

      return AppPermissionStatus.denied;
    } catch (e) {
      return AppPermissionStatus.denied;
    }
  }

  static Future<AppPermissionStatus> requestStoragePermission() async {
    try {
      final isAndroid13Plus = await isAndroid13OrHigher();

      if (isAndroid13Plus) {
        List<Permission> permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        for (var permission in permissions) {
          final status = await permission.request();
          if (status.isGranted) {
            return AppPermissionStatus.granted;
          }
          if (status.isPermanentlyDenied) {
            continue;
          }
        }
        if (await Permission.photos.isPermanentlyDenied &&
            await Permission.videos.isPermanentlyDenied &&
            await Permission.audio.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
      } else {
        var status = await Permission.storage.request();

        if (status.isGranted) {
          return AppPermissionStatus.granted;
        }

        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
          if (status.isGranted) {
            return AppPermissionStatus.granted;
          }
        }

        if (await Permission.storage.isPermanentlyDenied &&
            await Permission.manageExternalStorage.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
      }

      return AppPermissionStatus.denied;
    } catch (e) {
      return AppPermissionStatus.denied;
    }
  }

  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  static AppPermissionStatus mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return AppPermissionStatus.granted;
      case PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return AppPermissionStatus.restricted;
    }
  }
}
