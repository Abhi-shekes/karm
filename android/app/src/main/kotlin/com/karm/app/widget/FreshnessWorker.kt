package com.karm.app.widget

import android.content.Context
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkerParameters
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

private const val UNIQUE_WORK_NAME = "karm_widget_freshness_tick"

/**
 * Forces a redraw of the widgets that show elapsed-time text (the
 * "Updated Xm ago" label on the Today widget, the countdown on the Focus
 * widget) on a schedule, independent of the app being open. It doesn't
 * fetch new data — the widget process can't reach the Drift database —
 * it just recomputes those labels from timestamps already cached in
 * shared prefs, so the widget stops looking frozen when the app is
 * closed for a while.
 */
class FreshnessWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        TodayWidget().updateAll(applicationContext)
        FocusWidget().updateAll(applicationContext)
        return Result.success()
    }
}

fun scheduleFreshnessTicks(context: Context) {
    val request = PeriodicWorkRequestBuilder<FreshnessWorker>(15, TimeUnit.MINUTES).build()
    WorkManager.getInstance(context)
        .enqueueUniquePeriodicWork(UNIQUE_WORK_NAME, ExistingPeriodicWorkPolicy.KEEP, request)
}

fun cancelFreshnessTicks(context: Context) {
    WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
}
