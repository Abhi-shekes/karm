import 'package:flutter_test/flutter_test.dart';
import 'package:karm/features/recurring/recurrence.dart';

void main() {
  group('nextDueDateFor', () {
    test('daily adds one day', () {
      final due = DateTime(2026, 7, 24, 9, 0);
      expect(nextDueDateFor(RecurrenceRule.daily, due), DateTime(2026, 7, 25, 9, 0));
    });

    test('weekly adds seven days', () {
      final due = DateTime(2026, 7, 24);
      expect(nextDueDateFor(RecurrenceRule.weekly, due), DateTime(2026, 7, 31));
    });

    test('monthly rolls over a year boundary', () {
      final due = DateTime(2026, 12, 15);
      expect(nextDueDateFor(RecurrenceRule.monthly, due), DateTime(2027, 1, 15));
    });

    test('falls back to now when there is no current due date', () {
      final before = DateTime.now();
      final next = nextDueDateFor(RecurrenceRule.daily, null);
      expect(next.isAfter(before) || next.isAtSameMomentAs(before), isTrue);
    });
  });
}
