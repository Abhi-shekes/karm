package com.karm.app.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class TodayWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = TodayWidget()

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleFreshnessTicks(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        cancelFreshnessTicks(context)
    }
}
