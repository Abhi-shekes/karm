import * as admin from "firebase-admin";
import {onDocumentWritten, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions/v2";

admin.initializeApp();
const db = admin.firestore();

/**
 * Keeps `lists/{listId}.memberIds` (used for client-side list queries) in
 * sync with the `members` subcollection, which is the source of truth for
 * roles. Clients are not allowed to write `memberIds` directly (see
 * firestore.rules) — only this function does, so the array can't be
 * tampered with to grant unauthorized read access.
 */
export const syncMemberIds = onDocumentWritten(
  "lists/{listId}/members/{memberId}",
  async (event) => {
    const {listId} = event.params;
    const membersSnap = await db.collection("lists").doc(listId).collection("members").get();
    const memberIds = membersSnap.docs.map((doc) => doc.id);
    await db.collection("lists").doc(listId).update({memberIds});
  }
);

/**
 * Advances a recurring task to its next occurrence when it's marked done.
 * Owned server-side (rather than by whichever client happens to make the
 * edit) so two collaborators completing the same recurring task at once
 * can't create duplicate next-occurrences.
 */
export const advanceRecurringTask = onDocumentUpdated(
  "lists/{listId}/tasks/{taskId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.done || !after.done) return; // only fire on false -> true
    if (!after.recurrenceRule) return;

    const nextDueDate = computeNextDueDate(after.recurrenceRule, after.dueDate?.toDate());

    await db
      .collection("lists")
      .doc(event.params.listId)
      .collection("tasks")
      .add({
        title: after.title,
        notes: after.notes ?? null,
        dueDate: nextDueDate ? admin.firestore.Timestamp.fromDate(nextDueDate) : null,
        priority: after.priority ?? 0,
        tags: after.tags ?? [],
        assigneeId: after.assigneeId ?? null,
        status: "open",
        recurrenceRule: after.recurrenceRule,
        done: false,
        createdBy: after.createdBy,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        sortOrder: after.sortOrder ?? 0,
      });
  }
);

function computeNextDueDate(rule: string, current?: Date): Date | null {
  const base = current ?? new Date();
  switch (rule) {
    case "daily":
      return new Date(base.getTime() + 24 * 60 * 60 * 1000);
    case "weekly":
      return new Date(base.getTime() + 7 * 24 * 60 * 60 * 1000);
    case "monthly": {
      const next = new Date(base);
      next.setMonth(next.getMonth() + 1);
      return next;
    }
    default:
      return null;
  }
}

/**
 * Pushes a notification to a task's assignee when they're newly assigned
 * on a shared list. Personal, non-shared tasks never hit this path since
 * they never leave the device's local database.
 */
export const notifyOnAssignment = onDocumentUpdated(
  "lists/{listId}/tasks/{taskId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.assigneeId === after.assigneeId || !after.assigneeId) return;
    if (after.assigneeId === after.createdBy) return; // don't notify self-assignment

    const userDoc = await db.collection("users").doc(after.assigneeId).get();
    const tokens: string[] = userDoc.data()?.fcmTokens ?? [];
    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "New task assigned to you",
        body: after.title,
      },
      data: {listId: event.params.listId, taskId: event.params.taskId},
    });
  }
);

/**
 * Every 15 minutes, pushes a reminder for shared-list tasks due in the
 * next window. Personal reminders are handled entirely on-device via
 * flutter_local_notifications; this exists for collaborators who need a
 * heads-up on a task even when they're not the one who set the due date.
 */
export const dueSoonReminders = onSchedule("every 15 minutes", async () => {
  const now = admin.firestore.Timestamp.now();
  const windowEnd = admin.firestore.Timestamp.fromMillis(now.toMillis() + 15 * 60 * 1000);

  const dueSoon = await db
    .collectionGroup("tasks")
    .where("done", "==", false)
    .where("dueDate", ">=", now)
    .where("dueDate", "<", windowEnd)
    .get();

  logger.info(`Found ${dueSoon.size} shared tasks due in the next 15 minutes.`);

  for (const doc of dueSoon.docs) {
    const task = doc.data();
    const recipientId = task.assigneeId ?? task.createdBy;
    if (!recipientId) continue;

    const userDoc = await db.collection("users").doc(recipientId).get();
    const tokens: string[] = userDoc.data()?.fcmTokens ?? [];
    if (tokens.length === 0) continue;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {title: "Due soon", body: task.title},
      data: {listId: doc.ref.parent.parent?.id ?? "", taskId: doc.id},
    });
  }
});
