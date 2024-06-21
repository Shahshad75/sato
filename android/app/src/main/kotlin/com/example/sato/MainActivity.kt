package com.example.sato

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "imageUploader/sharedImage"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedImage" -> {
                    val intent = intent
                    if (intent.action == Intent.ACTION_SEND) {
                        val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                        result.success(uri?.toString())
                    } else {
                        result.success(null)
                    }
                }
                "readBytes" -> {
                    val uriString = call.arguments<String>()
                    val uri = Uri.parse(uriString)
                    val contentResolver = applicationContext.contentResolver
                    val inputStream: InputStream? = contentResolver.openInputStream(uri)
                    val bytes = inputStream?.readBytes()
                    inputStream?.close()
                    if (bytes != null) {
                        result.success(bytes)
                    } else {
                        result.error("UNAVAILABLE", "Could not read bytes from content URI", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent = getIntent()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        methodChannel.invokeMethod("newIntent", null) // Notify Flutter about the new intent
    }
}
