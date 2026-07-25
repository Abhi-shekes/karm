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
import androidx.glance.layout.Alignment
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
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
    // Exact (not a fixed set of breakpoints) so the layout always matches
    // whatever size the launcher actually grants it — the task list scrolls
    // instead of being silently clipped when there isn't room for every row.
    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val tasks = parseTasks(prefs.getString("today_tasks", "[]") ?: "[]")
        val lastUpdated = prefs.getLong("last_updated", 0L)

        provideContent { WidgetContent(tasks, lastUpdated) }
    }

    private fun parseTasks(json: String): List<WidgetTask> {
        val array = JSONArray(json)
        val count = minOf(array.length(), 8)
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

/** "just now" / "3m ago" / "2h ago", recomputed on every widget render. */
fun relativeTime(epochMillis: Long): String {
    if (epochMillis <= 0L) return ""
    val elapsedMin = (System.currentTimeMillis() - epochMillis) / 60000
    return when {
        elapsedMin < 1 -> "Updated just now"
        elapsedMin < 60 -> "Updated ${elapsedMin}m ago"
        elapsedMin < 24 * 60 -> "Updated ${elapsedMin / 60}h ago"
        else -> "Updated ${elapsedMin / (24 * 60)}d ago"
    }
}

@Composable
private fun WidgetContent(tasks: List<WidgetTask>, lastUpdated: Long) {
    // Deliberately NOT gating layout on LocalSize here: several OEM
    // launchers (this was found on a ColorOS/Realme device) don't report
    // accurate widget height through the AppWidgetManager options bundle,
    // so a "hide the list below N dp" check can fire even when the widget
    // is visually large, hiding all the tasks. The LazyColumn below already
    // degrades gracefully (scrolls, or shows nothing) at genuinely small
    // sizes, so there's no need to pre-emptively hide it.
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
            .padding(horizontal = 14.dp, vertical = 12.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = "Today",
                style = TextStyle(color = ColorProvider(ink), fontSize = 14.sp, fontWeight = FontWeight.Medium),
                modifier = GlanceModifier.defaultWeight().clickable(openApp),
            )
            Text(
                text = "+ Add",
                style = TextStyle(color = ColorProvider(indigo), fontSize = 13.sp, fontWeight = FontWeight.Medium),
                modifier = GlanceModifier.padding(4.dp).clickable(openAddTask),
            )
        }
        Spacer(modifier = GlanceModifier.size(4.dp))

        if (tasks.isEmpty()) {
            Text(
                text = "Nothing due today",
                style = TextStyle(color = ColorProvider(inkMuted), fontSize = 12.sp),
                modifier = GlanceModifier.padding(vertical = 8.dp),
            )
        } else {
            LazyColumn(modifier = GlanceModifier.defaultWeight()) {
                items(tasks, itemId = { it.id.hashCode().toLong() }) { task ->
                    TaskRow(task, openApp)
                }
            }
        }

        if (lastUpdated > 0L) {
            Text(
                text = relativeTime(lastUpdated),
                style = TextStyle(color = ColorProvider(inkMuted), fontSize = 10.sp),
            )
        }
    }
}

@Composable
private fun TaskRow(task: WidgetTask, openApp: androidx.glance.action.Action) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = GlanceModifier.fillMaxWidth().padding(vertical = 6.dp),
    ) {
        // The checkbox's own visible glyph is small and quiet (mirrors the
        // in-app KarmCheckbox), but its clickable area is padded out well
        // past that so a real fingertip reliably lands on "toggle" instead
        // of missing and hitting the title's "open app" tap target next to
        // it.
        Box(
            modifier = GlanceModifier
                .padding(6.dp)
                .clickable(actionRunCallback<ToggleTaskAction>(actionParametersOf(taskIdKey to task.id))),
        ) {
            Box(
                modifier = GlanceModifier
                    .size(22.dp)
                    .cornerRadius(6.dp)
                    .background(hairline),
            ) {
                Box(
                    modifier = GlanceModifier
                        .padding(2.dp)
                        .size(18.dp)
                        .cornerRadius(5.dp)
                        .background(if (task.done) sage else paper),
                ) {
                    if (task.done) {
                        Box(modifier = GlanceModifier.fillMaxSize()) {
                            Text(
                                text = "✓",
                                style = TextStyle(color = ColorProvider(paper), fontSize = 11.sp),
                            )
                        }
                    }
                }
            }
        }
        Spacer(modifier = GlanceModifier.width(10.dp))
        Text(
            text = task.title,
            maxLines = 1,
            style = TextStyle(
                color = ColorProvider(if (task.done) inkMuted else ink),
                fontSize = 13.sp,
            ),
            modifier = GlanceModifier.defaultWeight().padding(vertical = 4.dp).clickable(openApp),
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
        editor.putLong("last_updated", System.currentTimeMillis())

        val pending = JSONArray(prefs.getString("pending_toggles", "[]") ?: "[]")
        pending.put(taskId)
        editor.putString("pending_toggles", pending.toString())
        editor.apply()

        TodayWidget().updateAll(context)
    }
}
