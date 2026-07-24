import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/presentation/calendar_screen.dart';
import '../features/focus_timer/presentation/focus_timer_screen.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/lists/presentation/list_detail_screen.dart';
import '../features/lists/presentation/lists_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/today_screen.dart';
import '../features/tasks/presentation/upcoming_screen.dart';
import 'shell_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _todayNavigatorKey = GlobalKey<NavigatorState>();
final _upcomingNavigatorKey = GlobalKey<NavigatorState>();
final _calendarNavigatorKey = GlobalKey<NavigatorState>();
final _listsNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _todayNavigatorKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _upcomingNavigatorKey,
          routes: [
            GoRoute(
              path: '/upcoming',
              builder: (context, state) => const UpcomingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _calendarNavigatorKey,
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _listsNavigatorKey,
          routes: [
            GoRoute(
              path: '/lists',
              builder: (context, state) => const ListsScreen(),
              routes: [
                GoRoute(
                  path: ':listId',
                  builder: (context, state) => ListDetailScreen(
                    listId: state.pathParameters['listId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/focus-timer',
      builder: (context, state) => const FocusTimerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
  ],
);
