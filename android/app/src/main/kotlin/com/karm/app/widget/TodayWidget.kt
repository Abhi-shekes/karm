package com.karm.app.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalContext
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.karm.app.MainActivity
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

// Mirrors the app's light-mode "paper & ink" design tokens (see
// lib/core/design/app_colors.dart) — Glance widgets can't read the app's
// Dart ThemeData, so the palette is duplicated here deliberately.
private val paper = Color(0xFFFAF8F4)
private val ink = Color(0xFF1E1B16)
private val inkMuted = Color(0xFF6B6459)
private val indigo = Color(0xFF33367D)
private val sage = Color(0xFF5E7D5A)
private val hairline = Color(0xFFE7E1D4)

val taskIdKey = ActionParameters.Key<String>("taskId")

private data class WidgetTask(val id: String, val title: String, val done: Boolean)

class TodayWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val tasks = parseTasks(prefs.getString("today_tasks", "[]") ?: "[]")

        provideContent { WidgetContent(tasks) }
    }

    private fun parseTasks(json: String): List<WidgetTask> {
        val array = JSONArray(json)
        val count = minOf(array.length(), 4)
        return (0 until count).map { i ->
            val obj = array.getJSONObject(i)
            WidgetTask(
                id = obj.getString("id"),
                title = obj.getString("title"),
                done = obj.optBoolean("done", false),
            )
        }
    }
}

@Composable
private fun WidgetContent(tasks: List<WidgetTask>) {
    val context = LocalContext.current
    val openApp = actionStartActivity(Intent(context, MainActivity::class.java))
    val openAddTask = actionStartActivity(
        Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("karm://quick-add")
        }
    )

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(paper)
            .cornerRadius(16.dp)
            .padding(12.dp)
    ) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = "Today",
                style = TextStyle(color = ColorProvider(ink), fontSize = 13.sp, fontWeight = FontWeight.Medium),
                modifier = GlanceModifier.defaultWeight().clickable(openApp),
            )
            Text(
                text = "+ Add",
                style = TextStyle(color = ColorProvider(indigo), fontSize = 12.sp, fontWeight = FontWeight.Medium),
                modifier = GlanceModifier.clickable(openAddTask),
            )
        }
        Spacer(modifier = GlanceModifier.size(8.dp))

        if (tasks.isEmpty()) {
            Text(
                text = "Nothing due today",
                style = TextStyle(color = ColorProvider(inkMuted), fontSize = 12.sp),
            )
        } else {
            tasks.forEach { task -> TaskRow(task, openApp) }
        }
    }
}

@Composable
private fun TaskRow(task: WidgetTask, openApp: androidx.glance.action.Action) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().padding(vertical = 4.dp),
    ) {
        Box(
            modifier = GlanceModifier
                .size(18.dp)
                .cornerRadius(5.dp)
                .background(if (task.done) sage else paper)
                .clickable(actionRunCallback<ToggleTaskAction>(actionParametersOf(taskIdKey to task.id))),
        ) {
            if (task.done) {
                Text(text = "✓", style = TextStyle(color = ColorProvider(paper), fontSize = 11.sp))
            }
        }
        Spacer(modifier = GlanceModifier.width(8.dp))
        Text(
            text = task.title,
            maxLines = 1,
            style = TextStyle(
                color = ColorProvider(if (task.done) inkMuted else ink),
                fontSize = 13.sp,
            ),
            modifier = GlanceModifier.clickable(openApp),
        )
    }
}

/**
 * Flips the task's done state in the widget's own cached copy for
 * instant visual feedback, and queues the id in `pending_toggles` for the
 * app to apply to the real database next time it's opened — the widget
 * process has no access to the Drift/SQLite database directly.
 */
class ToggleTaskAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val taskId = parameters[taskIdKey] ?: return
        val prefs = HomeWidgetPlugin.getData(context)
        val editor = prefs.edit()

        val tasks = JSONArray(prefs.getString("today_tasks", "[]") ?: "[]")
        for (i in 0 until tasks.length()) {
            val obj = tasks.getJSONObject(i)
            if (obj.getString("id") == taskId) {
                obj.put("done", !obj.optBoolean("done", false))
            }
        }
        editor.putString("today_tasks", tasks.toString())

        val pending = JSONArray(prefs.getString("pending_toggles", "[]") ?: "[]")
        pending.put(taskId)
        editor.putString("pending_toggles", pending.toString())
        editor.apply()

        TodayWidget().updateAll(context)
    }
}
