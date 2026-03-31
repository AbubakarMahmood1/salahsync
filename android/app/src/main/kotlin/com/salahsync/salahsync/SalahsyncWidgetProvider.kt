package com.salahsync.salahsync

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.text.format.DateFormat
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONException
import java.util.Date

class SalahsyncWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val nextPrayer = resolveNextPrayer(widgetData)
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.salahsync_widget).apply {
                val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
                setTextViewText(
                    R.id.widget_location,
                    widgetData.getString("widget_location_name", "SalahSync"),
                )
                setTextViewText(R.id.widget_prayer_name, nextPrayer.label)
                setTextViewText(
                    R.id.widget_time,
                    DateFormat.format("HH:mm", Date(nextPrayer.timeMillis)),
                )
                setTextViewText(
                    R.id.widget_hijri,
                    widgetData.getString("widget_hijri_label", ""),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun resolveNextPrayer(widgetData: SharedPreferences): WidgetPrayerEntry {
        val now = System.currentTimeMillis()
        val rawSchedule = widgetData.getString("widget_schedule_json", "[]") ?: "[]"
        val parsed = mutableListOf<WidgetPrayerEntry>()
        try {
            val schedule = JSONArray(rawSchedule)
            for (index in 0 until schedule.length()) {
                val item = schedule.getJSONObject(index)
                parsed.add(
                    WidgetPrayerEntry(
                        label = item.optString("label", "Prayer"),
                        timeMillis = item.optLong("timeMillis", now),
                    ),
                )
            }
        } catch (_: JSONException) {
        }

        return parsed.firstOrNull { it.timeMillis >= now }
            ?: parsed.firstOrNull()
            ?: WidgetPrayerEntry(
                label = widgetData.getString("widget_next_prayer_label", "Prayer") ?: "Prayer",
                timeMillis = widgetData.getLong("widget_next_prayer_time", now),
            )
    }
}

private data class WidgetPrayerEntry(
    val label: String,
    val timeMillis: Long,
)
