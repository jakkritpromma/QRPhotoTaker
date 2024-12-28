package com.jakkagaku.qrphototaker
import android.annotation.TargetApi
import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import java.io.File

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jakkagaku.qrphototaker/media_scan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Log to confirm this method is being called
        Log.d("MainActivity", "MethodChannel configured")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                Log.d("MainActivity", "Received path in scanFile: $path")
                if (path != null) {
                    scanFile(this, path)
                    result.success("File scanned successfully.")
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.FROYO)
    private fun scanFile(context: Context, path: String) {
        val file = File(path)
        if (!file.exists()) {
            Log.e("MainActivity", "File does not exist: $path")
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
                put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                put(MediaStore.MediaColumns.RELATIVE_PATH, "DCIM/Camera")
            }
            context.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)?.let { uri ->
                context.contentResolver.openOutputStream(uri).use { outputStream ->
                    file.inputStream().copyTo(outputStream!!)
                }
            }
        } else {
            MediaScannerConnection.scanFile(context, arrayOf(path), null, null)
        }
    }

}
