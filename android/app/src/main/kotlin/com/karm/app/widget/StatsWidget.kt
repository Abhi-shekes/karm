package com.karm.app.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalContext
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.karm.app.MainActivity
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

private val paper = Color(0xFFFAF8F4)
private val inkMuted = Color(0xFF6B6459)
private val sage = Color(0xFF5E7D5A)
private val amber = Color(0xFFB9873A)

/** Today's completed/total count + streak — reuses the same `today_tasks`
 * snapshot the Today widget already receives, plus a `streak` field
 * pushed alongside it by [HomeWidgetSync]. */
class StatsWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val tasks = JSONArray(prefs.getString("today_tasks", "[]") ?: "[]")
        var total = 0
        var completed = 0
        for (i in 0 until tasks.length()) {
            total++
            if (tasks.getJSONObject(i).optBoolean("done", false)) completed++
        }
        val streak = prefs.getInt("streak", 0)

        provideContent { StatsWidgetContent(completed, total, streak) }
    }
}

@Composable
private fun StatsWidgetContent(completed: Int, total: Int, streak: Int) {
    val context = LocalContext.current
    val openApp = actionStartActivity(Intent(context, MainActivity::class.java))

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(paper)
            .cornerRadius(16.dp)
            .padding(12.dp)
            .clickable(openApp),
    ) {
        Text(
            text = "Today",
            style = TextStyle(color = ColorProvider(inkMuted), fontSize = 12.sp, fontWeight = FontWeight.Medium),
        )
        Spacer(modifier = GlanceModifier.size(4.dp))
        Text(
            text = "$completed/$total",
            style = TextStyle(color = ColorProvider(sage), fontSize = 22.sp, fontWeight = FontWeight.Medium),
        )
        Spacer(modifier = GlanceModifier.size(6.dp))
        Row {
            Text(
                text = "🔥 $streak day${if (streak == 1) "" else "s"}",
                style = TextStyle(color = ColorProvider(amber), fontSize = 12.sp, fontWeight = FontWeight.Medium),
            )
        }
    }
}
