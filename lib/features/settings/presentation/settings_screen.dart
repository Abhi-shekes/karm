import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme_mode_provider.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';
import '../../friends/application/friends_providers.dart';
import '../application/profile_stats_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final themeMode = ref.watch(appThemeModeProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) _ProfileHeader(user: user),
          const SizedBox(height: 24),
          const _StatsRow(),
          const SizedBox(height: 24),
          const _FriendsPreview(),
          const SizedBox(height: 28),
          _SectionCard(
            title: 'Appearance',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(appThemeModeProvider.notifier).set(selection.first),
            ),
          ),
          const SizedBox(height: 36),
          OutlinedButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            style: OutlinedButton.styleFrom(foregroundColor: colors.clay),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  String get _initials {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final letters = parts.take(2).map((p) => p[0]).join();
      return letters.toUpperCase();
    }
    final email = user.email;
    return email != null && email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final photoUrl = user.photoURL;
    final createdAt = user.metadata.creationTime;

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colors.indigo.withValues(alpha: 0.15),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  _initials,
                  style: type.sectionTitle.copyWith(color: colors.indigo),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName ?? user.email ?? 'Signed in', style: type.taskTitle),
              if (user.email != null) ...[
                const SizedBox(height: 2),
                Text(user.email!, style: type.taskNotes),
              ],
              if (createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Member since ${DateFormat('MMMM yyyy').format(createdAt)}',
                  style: type.caption,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);
    final stats = statsAsync.value;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Today',
            value: stats == null ? '—' : '${stats.todayCompleted}/${stats.todayTotal}',
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Streak',
            value: stats == null ? '—' : '${stats.streak}d',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'All time',
            value: stats == null ? '—' : '${stats.allTimeCompleted}',
            icon: Icons.emoji_events_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: colors.indigo),
          const SizedBox(height: 8),
          Text(value, style: type.dateStamp.copyWith(fontSize: 16, color: colors.ink)),
          const SizedBox(height: 2),
          Text(label, style: type.caption),
        ],
      ),
    );
  }
}

class _FriendsPreview extends ConsumerWidget {
  const _FriendsPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final friendsAsync = ref.watch(friendsProvider);
    final friends = friendsAsync.value ?? const [];

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/friends'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.hairline),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: colors.ink),
            const SizedBox(width: 12),
            if (friends.isNotEmpty) ...[
              SizedBox(
                width: 20.0 + (friends.length.clamp(0, 4) - 1) * 16.0,
                height: 28,
                child: Stack(
                  children: [
                    for (var i = 0; i < friends.take(4).length; i++)
                      Positioned(
                        left: i * 16.0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: colors.paper,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: colors.sage.withValues(alpha: 0.25),
                            backgroundImage: friends[i].photoUrl != null
                                ? NetworkImage(friends[i].photoUrl!)
                                : null,
                            child: friends[i].photoUrl == null
                                ? Text(
                                    friends[i].label[0].toUpperCase(),
                                    style: type.caption.copyWith(color: colors.sage),
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                friends.isEmpty ? 'Friends' : '${friends.length} friends',
                style: type.taskTitle,
              ),
            ),
            Icon(Icons.chevron_right, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final type = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: type.sectionTitle),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
