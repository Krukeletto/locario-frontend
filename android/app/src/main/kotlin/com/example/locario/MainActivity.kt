package com.example.locario

import android.content.Intent
import android.provider.CalendarContract
import android.provider.CalendarContract.Events
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val CHANNEL_NAME = "locario/device_calendar"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method != "createEvent") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val title = call.argument<String>("title")?.trim().orEmpty()
                val startMillis = call.argument<Number>("startMillis")?.toLong()
                val endMillis = call.argument<Number>("endMillis")?.toLong()
                if (title.isEmpty() || startMillis == null || endMillis == null) {
                    result.error("invalid_args", "Missing calendar event data", null)
                    return@setMethodCallHandler
                }

                val intent = Intent(Intent.ACTION_INSERT).apply {
                    data = Events.CONTENT_URI
                    putExtra(Events.TITLE, title)
                    call.argument<String>("description")
                        ?.trim()
                        ?.takeIf { it.isNotEmpty() }
                        ?.let { putExtra(Events.DESCRIPTION, it) }
                    call.argument<String>("location")
                        ?.trim()
                        ?.takeIf { it.isNotEmpty() }
                        ?.let { putExtra(Events.EVENT_LOCATION, it) }
                    putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startMillis)
                    putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endMillis)
                }

                try {
                    startActivity(intent)
                    result.success(true)
                } catch (error: Exception) {
                    result.error("calendar_intent_failed", error.message, null)
                }
            }
    }
}
