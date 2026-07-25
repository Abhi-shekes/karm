import 'package:flutter_test/flutter_test.dart';
import 'package:karm/features/settings/application/profile_stats_provider.dart';

void main() {
  group('streakFromCompletedDates', () {
    final now = DateTime.now();
    DateTime daysAgo(int n) => DateTime(now.year, now.month, now.day).subtract(Duration(days: n));

    test('is zero with no completed days', () {
      expect(streakFromCompletedDates([]), 0);
    });

    test('counts consecutive days ending today', () {
      final dates = [daysAgo(0), daysAgo(1), daysAgo(2)];
      expect(streakFromCompletedDates(dates), 3);
    });

    test('still counts when today is missing but yesterday is present', () {
      final dates = [daysAgo(1), daysAgo(2), daysAgo(3)];
      expect(streakFromCompletedDates(dates), 3);
    });

    test('is zero once both today and yesterday are missing', () {
      final dates = [daysAgo(2), daysAgo(3)];
      expect(streakFromCompletedDates(dates), 0);
    });

    test('stops at the first gap', () {
      final dates = [daysAgo(0), daysAgo(1), daysAgo(3)];
      expect(streakFromCompletedDates(dates), 2);
    });
  });
}
