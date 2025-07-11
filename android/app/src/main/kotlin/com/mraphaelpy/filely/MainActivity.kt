package com.mraphaelpy.filely

import android.os.StatFs
import android.os.Environment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "mraphaelpy.filely/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStorageFreeSpace" -> {
                    try {
                        val freeSpace = getInternalStorageFreeSpace()
                        result.success(freeSpace)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Free space not available.", null)
                    }
                }
                "getStorageTotalSpace" -> {
                    try {
                        val totalSpace = getInternalStorageTotalSpace()
                        result.success(totalSpace)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Total space not available.", null)
                    }
                }
                "getExternalStorageFreeSpace" -> {
                    try {
                        val freeSpace = getExternalStorageFreeSpace()
                        result.success(freeSpace)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "External free space not available.", null)
                    }
                }
                "getExternalStorageTotalSpace" -> {
                    try {
                        val totalSpace = getExternalStorageTotalSpace()
                        result.success(totalSpace)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "External total space not available.", null)
                    }
                }
                "getStorageInfo" -> {
                    try {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            val storageInfo = getStorageInfo(path)
                            result.success(storageInfo)
                        } else {
                            result.error("INVALID_ARGUMENT", "Path is required.", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Storage info not available.", null)
                    }
                }
                "getAndroidSdkVersion" -> {
                    try {
                        val sdkVersion = android.os.Build.VERSION.SDK_INT
                        result.success(sdkVersion)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "SDK Version not available.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInternalStorageFreeSpace(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        return stat.blockSizeLong * stat.availableBlocksLong
    }

    private fun getInternalStorageTotalSpace(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        return stat.blockSizeLong * stat.blockCountLong
    }

    private fun getExternalStorageFreeSpace(): Long {
        return if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
            val stat = StatFs(Environment.getExternalStorageDirectory().path)
            stat.blockSizeLong * stat.availableBlocksLong
        } else {
            0L
        }
    }

    private fun getExternalStorageTotalSpace(): Long {
        return if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
            val stat = StatFs(Environment.getExternalStorageDirectory().path)
            stat.blockSizeLong * stat.blockCountLong
        } else {
            0L
        }
    }

    private fun getStorageInfo(path: String): Map<String, Long> {
        val file = File(path)
        if (!file.exists()) {
            return mapOf(
                "total" to 0L,
                "free" to 0L,
                "used" to 0L
            )
        }
        
        try {
            val stat = StatFs(file.path)
            
            val total = stat.blockSizeLong * stat.blockCountLong
            val free = stat.blockSizeLong * stat.availableBlocksLong
            
            return mapOf(
                "total" to total,
                "free" to free,
                "used" to (total - free)
            )
        } catch (e: Exception) {
            return mapOf(
                "total" to 0L,
                "free" to 0L,
                "used" to 0L
            )
        }
    }
}