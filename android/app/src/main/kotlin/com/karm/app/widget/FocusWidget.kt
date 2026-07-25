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
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.karm.app.MainActivity
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

private val paper = Color(0xFFFAF8F4)
private val ink = Color(0xFF1E1B16)
private val inkMuted = Color(0xFF6B6459)
private val indigo = Color(0xFF33367D)

private data class FocusState(
    val phaseLabel: String,
    val isRunning: Boolean,
    val remainingSeconds: Int,
    val endTime: Long?,
)

/**
 * Shows the current focus/break status. Glance widgets can't tick every
 * second, so — mirroring [FocusTimerController]'s own "derive remaining
 * from endTime" approach — this recomputes the remaining time from the
 * cached [FocusState.endTime] on each redraw (app-open pushes, or the
 * periodic [FreshnessWorker] tick), which is minute-level accurate rather
 * than a live stopwatch.
 */
class FocusWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = HomeWidgetPlugin.getData(context)
        val state = parseState(prefs.getString("focus_state", null))
        provideContent { FocusWidgetContent(state) }
    }

    private fun parseState(json: String?): FocusState? {
        if (json.isNullOrEmpty()) return null
        val obj = JSONObject(json)
        return FocusState(
            phaseLabel = obj.optString("phaseLabel", "Focus"),
            isRunning = obj.optBoolean("isRunning", false),
            remainingSeconds = obj.optInt("remainingSeconds", 0),
            endTime = if (obj.isNull("endTime")) null else obj.optLong("endTime"),
        )
    }
}

@Composable
private fun FocusWidgetContent(state: FocusState?) {
    val context = LocalContext.current
    val openApp = actionStartActivity(Intent(context, MainActivity::class.java))

    val remainingSeconds = when {
        state == null -> 25 * 60
        state.isRunning && state.endTime != null ->
            maxOf(0, ((state.endTime - System.currentTimeMillis()) / 1000).toInt())
        else -> state.remainingSeconds
    }
    val minutes = remainingSeconds / 60
    val seconds = remainingSeconds % 60

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(paper)
            .cornerRadius(16.dp)
            .padding(12.dp)
            .clickable(openApp),
    ) {
        Text(
            text = state?.phaseLabel ?: "Focus",
            style = TextStyle(color = ColorProvider(ink), fontSize = 13.sp, fontWeight = FontWeight.Medium),
        )
        Spacer(modifier = GlanceModifier.size(4.dp))
        Text(
            text = "%02d:%02d".format(minutes, seconds),
            style = TextStyle(color = ColorProvider(indigo), fontSize = 24.sp, fontWeight = FontWeight.Medium),
        )
        Spacer(modifier = GlanceModifier.size(8.dp))
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = if (state?.isRunning == true) "Pause" else "Start",
                style = TextStyle(color = ColorProvider(indigo), fontSize = 12.sp, fontWeight = FontWeight.Medium),
                modifier = GlanceModifier.clickable(actionRunCallback<ToggleFocusAction>()),
            )
        }
    }
}

/**
 * Flips the widget's own cached focus state for instant feedback (same
 * pattern as [ToggleTaskAction]) and queues the intent for the app to
 * apply to the real [FocusTimerController] next time it's opened — the
 * widget process can't reach the in-memory Riverpod controller directly.
 */
class ToggleFocusAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val editor = prefs.edit()

        val raw = prefs.getString("focus_state", null)
        val obj = if (raw.isNullOrEmpty()) JSONObject() else JSONObject(raw)
        val wasRunning = obj.optBoolean("isRunning", false)
        val now = System.currentTimeMillis()

        if (wasRunning) {
            val endTime = if (obj.isNull("endTime")) now else obj.optLong("endTime")
            obj.put("remainingSeconds", maxOf(0, ((endTime - now) / 1000).toInt()))
            obj.put("endTime", JSONObject.NULL)
            obj.put("isRunning", false)
            editor.putString("pending_focus_action", "pause")
        } else {
            val remaining = obj.optInt("remainingSeconds", 25 * 60)
            obj.put("endTime", now + remaining * 1000L)
            obj.put("isRunning", true)
            editor.putString("pending_focus_action", "start")
        }
        editor.putString("focus_state", obj.toString())
        editor.apply()

        FocusWidget().updateAll(context)
    }
}
