/// Simplified recurrence rules — an "RRULE-lite" of just the common cases
/// a personal todo app needs, rather than a full RFC 5545 parser.
enum RecurrenceRule {
  daily,
  weekly,
  monthly;

  String get storageValue => name;

  static RecurrenceRule? fromStorage(String? value) {
    if (value == null) return null;
    for (final rule in RecurrenceRule.values) {
      if (rule.storageValue == value) return rule;
    }
    return null;
  }

  String get label => switch (this) {
        RecurrenceRule.daily => 'Daily',
        RecurrenceRule.weekly => 'Weekly',
        RecurrenceRule.monthly => 'Monthly',
      };
}

/// Computes the next due date after completing a recurring task.
DateTime nextDueDateFor(RecurrenceRule rule, DateTime? currentDue) {
  final base = currentDue ?? DateTime.now();
  switch (rule) {
    case RecurrenceRule.daily:
      return base.add(const Duration(days: 1));
    case RecurrenceRule.weekly:
      return base.add(const Duration(days: 7));
    case RecurrenceRule.monthly:
      return DateTime(base.year, base.month + 1, base.day, base.hour, base.minute);
  }
}
