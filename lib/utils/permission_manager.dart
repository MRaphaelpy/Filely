import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<bool> isAndroid11OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  Future<int> getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  Future<bool> hasManageExternalStoragePermission() async {
    if (await isAndroid11OrHigher()) {
      return await Permission.manageExternalStorage.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }

  Future<bool> requestPermission() async {
    bool isAndroid11OrHigher = await this.isAndroid11OrHigher();

    if (isAndroid11OrHigher) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      var status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    return false;
  }

  Future<bool> ensurePermissions() async {
    bool hasPermission = await hasManageExternalStoragePermission();
    if (!hasPermission) {
      hasPermission = await requestPermission();
    }
    return hasPermission;
  }
}
